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
  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.vpc.bastion_sg_id]
  env           = var.env
}
