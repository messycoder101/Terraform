variable "cidr_block" {
    type = list(string)
    default = ["172.20.0.0/16","172.20.10.0/24","172.20.11.0/24"]
}


variable "ports" {
    type = list(number)
    default = [22,80,443,8080,8081,9000]
}

variable "ami" {
    type = string
    default = "ami-0aeeebd8d2ab47354"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}


# variable "availability_zone" "subzone"{
#   default = ["us-east-1a", "us-east-1b"]
# }

variable "instance_type_for_nexus" {
    type = string
    default = "t2.medium"
}
