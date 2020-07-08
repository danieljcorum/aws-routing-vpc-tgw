variable "env" {
  description = "Environment or Common Name"
}

variable "vpc_cidr" {
  description = "IP cidr range for vpc"
}

variable "subnet_a" {
  description = "subnet for az a, recommend half of cidr"
}

variable "subnet_c" {
  description = "subnet for az c, recommend half of cidr"
}

variable "az1" {
  description = "first az for subnet a, recommend az1a"
}

variable "az2" {
  description = "second az for subnet c, recommend az1c"
}

variable "tgw_desc" {
  description = "descrition field for the transit gateway"
}

variable "tgw_name" {
  description = "name for transit gateway"
}

variable "tgw_rt_name" {
  description = "name for transit gateway route table"
}
