module "shell-resource" {
  source  = "Invicton-Labs/shell-resource/external"
  version = "0.3.3"
}

provider "aws" {
  region     = "eu-west-1"
}

module "network" {
  source    = "./modules/network"
  prefix = var.prefix
  az_list = var.az_list
  vpc_cidr_block = var.vpc_cidr_block
  private_cidr_block = var.private_cidr_block
  public_cidr_block = var.public_cidr_block
}

module "ec2" {
  source     = "./modules/ec2"
  prefix  = var.prefix
  az_list = var.az_list
  vpc_id        = module.network.vpc
  subnet_id  = module.network.subnet_id
  security_group = [ module.network.sg_ssh_pub, module.network.sg_icmp_pub]
}
