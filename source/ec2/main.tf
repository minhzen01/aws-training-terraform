resource "aws_instance" "bastion" {
  ami                         = var.ami_id_bastion     
  instance_type               = var.instance_type_bastion
  subnet_id                   = var.subnet_id_bastion
  associate_public_ip_address = true             

  vpc_security_group_ids = var.vpc_security_group_id_bastion

  key_name = "minh-quang-key-pair-virginia" 

  user_data = <<-EOF
              #!/bin/bash
              sudo echo "Port 8080" >> /etc/ssh/sshd_config
              sudo systemctl daemon-reload
              sudo systemctl restart ssh || sudo systemctl restart sshd
              EOF

  tags = {
    Name = "${var.env}-bastion"
  }
}

resource "aws_instance" "web-application" {
  ami                         = var.ami_id_web
  instance_type               = var.instance_type_web 
  subnet_id                   = var.subnet_id_web
  associate_public_ip_address = true                  

  vpc_security_group_ids = var.vpc_security_group_id_web

  key_name = "minh-quang-key-pair-virginia" 

  tags = {
    Name = "${var.env}-web-application"
  }
}


resource "aws_instance" "mysql" {
  ami                         = var.ami_id_db
  instance_type               = var.instance_type_db     
  subnet_id                   = var.subnet_id_db
  associate_public_ip_address = false                  

  vpc_security_group_ids = var.vpc_security_group_id_db

  key_name = "minh-quang-key-pair-virginia" 

  tags = {
    Name = "${var.env}-mysql"
  }
}

