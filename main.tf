# Configure the AWS Provider
provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

# # Terraform v12 required
# terraform {
#   required_version = "= 0.12.6"
# }

# Create a VPC
resource "aws_vpc" "tfVPC"{
    cidr_block = var.cidr_block[0]

    tags = {
        Name = "tf VPC"
    }

}

# Create Subnet

resource "aws_subnet" "tfPublicSubnet" {
    vpc_id = aws_vpc.tfVPC.id
    cidr_block = var.cidr_block[1]
    # az = data.aws_availability_zones.subzone[0]
    tags = {
        Name = "tf-Public-Subnet"
    }
}

resource "aws_subnet" "tfPrivateSubnet" {
    vpc_id = aws_vpc.tfVPC.id
    cidr_block = var.cidr_block[2]
    # availability_zone = data.aws_availability_zones.available.names[1]
    # az = data.availability_zones.subzone[1]
    tags = {
        Name = "tf-Private-Subnet"
    }
}

# Create Internet Gateway

resource "aws_internet_gateway" "tfIntGW" {
    vpc_id = aws_vpc.tfVPC.id

    tags = {
        Name = "tf InternetGW"
    }
}

# Create Security Group

resource "aws_security_group" "tf_Sec_Group" {
  name = "tf Security Group"
  description = "To allow inbound and outbound traffic to terraform"
  vpc_id = aws_vpc.tfVPC.id

  dynamic ingress {
      iterator = port
      for_each = var.ports
       content {
            from_port = port.value
            to_port = port.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
       }

  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
      Name = "allow traffic"
  }
}

#Creating a Load Balancer

resource "aws_lb" "tfLB" {
  name               = "tfLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_Sec_Group.id]
  subnets            = aws_subnet.tfPublicSubnet.*.id
  
#   availability_zone = var.availability_zone
  enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "tfLB"
#     enabled = true
#   }

  tags = {
    Environment = "test"
  }
}

#Configure Autoscaling

resource "aws_launch_configuration" "example-launchconfig" {
  name_prefix     = "example-launchconfig"
  image_id        = var.ami
  instance_type   = "t2.micro"
#   key_name        = aws_key_pair.mykeypair.key_name
  security_groups = [aws_security_group.tf_Sec_Group.id]
}

resource "aws_autoscaling_group" "example-autoscaling" {
  name                      = "example-autoscaling"
  vpc_zone_identifier       = [aws_subnet.tfPublicSubnet.id, aws_subnet.tfPrivateSubnet.id]
  launch_configuration      = aws_launch_configuration.example-launchconfig.name
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "ec2 instance"
    propagate_at_launch = true
  }
}

# scale up alarm

resource "aws_autoscaling_policy" "example-cpu-policy" {
  name                   = "example-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.example-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
  alarm_name          = "example-cpu-alarm"
  alarm_description   = "example-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.example-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.example-cpu-policy.arn]
}

# scale down alarm
resource "aws_autoscaling_policy" "example-cpu-policy-scaledown" {
  name                   = "example-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.example-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
  alarm_name          = "example-cpu-alarm-scaledown"
  alarm_description   = "example-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.example-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.example-cpu-policy-scaledown.arn]
}
