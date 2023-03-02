variable "prefix" {
  type = string
}

variable "vpc_cidr_block" {}

variable "subnet_count" {
    default = 3
}

variable "az_list" {}

variable "private_cidr_block" {}

variable "public_cidr_block" {}