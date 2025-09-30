env               = "dev"
cidr_block        = "10.10.0.0/16"
azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]

ami_id_bastion            = "ami-0360c520857e3138f"
instance_type_bastion     = "t2.micro"


ami_id_db            = "ami-0b8f248260c90c028"
instance_type_db     = "t2.medium"