Steps followed:
1. Configure the AWS Provider
2. Create a VPC - aws_vpc
3. Create Subnet - aws_subnet (public and private)
4. Create Internet Gateway - aws_internet_gateway
5. Create Security Group - aws_security_group
6. Creating a Load Balancer - aws_lb
7. Configure Autoscaling - aws_launch_configuration, aws_autoscaling_group
8. Crete Alarm Mechanism (scale up and down)- aws_cloudwatch_metric_alarm

Basic infrastructure is almost ready.

**main.tf** has some isssues to be sorted out.
1. Load Balancer module, named **tfLB** requires subnets in different Availability Zones --need to figure out how to configure the same.
2. Need to update subnet modules to include availability zones as well.
3. need to encrypt all data  at rest.
4. configure ASG to automatically add n remove nodes as per load.
