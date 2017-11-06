variable "key_name" {
  description = "The name of the configured key in AWS for SSH access"
}

variable "vpc_id" {
  description = "The vpc to place the instance in"
}

variable "subnet" {
  description = "The subnet to plae the instance in"
}

variable "ami" {
  description = "AWS AMI Id, if you change, make sure it is compatible with instance type, not all AMIs allow all instance types "

  default = {
    us-west-1      = "ami-1c1d217c"
    us-west-2      = "ami-0a00ce72"
    us-east-1      = "ami-da05a4a0"
    us-east-2      = "ami-336b4456"
    sa-east-1      = "ami-466b132a"
    eu-west-1      = "ami-add175d4"
    eu-west-2      = "ami-ecbea388"
    eu-central-1   = "ami-97e953f8"
    ca-central-1   = "ami-8a71c9ee"
    ap-southeast-1 = "ami-67a6e604"
    ap-southeast-2 = "ami-41c12e23"
    ap-south-1     = "ami-bc0d40d3"
    ap-northeast-1 = "ami-15872773"
    ap-northeast-2 = "ami-7b1cb915"
  }
}

variable "instance_type" {
  description = "The size instance to create"
  default     = "t2.micro"
}

variable "region" {
  description = "The region of AWS, for AMI lookups."
}

variable "psk" {
  description = "The pre-shared key for VPN"
}

variable "username" {
  description = "The VPN username"
}

variable "password" {
  description = "The password for the VPN user"
}
