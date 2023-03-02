variable "prefix" {
  default = "awesomeness"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "az_list" {
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "private_cidr_block" {
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_cidr_block" {
    type        = list(string)
    default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}