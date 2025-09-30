module "vpc" {
  source                = "../source/vpc"
  cidr_block            = var.cidr_block
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  env                   = var.env
}

module "ec2" {
  source                        = "../source/ec2"
  ami_id_bastion                = var.ami_id_bastion
  ami_id_db                     = var.ami_id_db
  ami_id_web                    = var.ami_id_web

  instance_type_bastion         = var.instance_type_bastion
  instance_type_db              = var.instance_type_db
  instance_type_web             = var.instance_type_web

  subnet_id_bastion             = module.vpc.public_subnets[0]
  subnet_id_db                  = module.vpc.private_subnets[0]
  subnet_id_web                 = module.vpc.public_subnets[0]

  vpc_security_group_id_bastion = [module.vpc.bastion_sg_id]
  vpc_security_group_id_db      = [module.vpc.db_sg_id]
  vpc_security_group_id_web     = [module.vpc.web_sg_id]

  env                           = var.env
}
