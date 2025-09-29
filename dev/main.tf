module "vpc" {
  source                = "../source/vpc"
  cidr_block            = var.cidr_block
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  env                   = var.env
}

module "ec2" {
  source        = "../source/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  env           = var.env
}
