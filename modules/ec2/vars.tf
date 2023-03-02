variable "vpc_id" {
}

variable "instance_count" {
    default = 3
}

variable "subnet_id" {
    type = list(string)
}

variable "az_list" {
}

variable "ami_id" {
    default = "ami-065793e81b1869261"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "security_group" {
  type = list(string)
}

variable "prefix" {
}

variable "private_key" {
  default = "~/.ssh/aws"
}