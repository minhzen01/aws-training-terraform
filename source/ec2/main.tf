resource "aws_instance" "bastion" {
  ami                         = var.ami_id_bastion     
  instance_type               = var.instance_type_bastion
  subnet_id                   = var.subnet_id_bastion
  associate_public_ip_address = true             

  vpc_security_group_ids = var.vpc_security_group_id_bastion

#   key_name = var.key_pair   

  tags = {
    Name = "${var.env}-bastion"
  }
}

resource "aws_instance" "mysql" {
  ami                         = var.ami_id_db
  instance_type               = var.instance_type_db     
  subnet_id                   = var.subnet_id_db
  associate_public_ip_address = false                  

  vpc_security_group_ids = var.vpc_security_group_id_db

  tags = {
    Name = "${var.env}-mysql"
  }
}

