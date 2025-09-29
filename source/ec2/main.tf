resource "aws_instance" "bastion" {
  ami                         = var.ami_id        
  instance_type               = var.instance_type 
  subnet_id                   = var.subnet_id  
  associate_public_ip_address = true             

  vpc_security_group_ids = var.vpc_security_group_ids

#   key_name = var.key_pair   

  tags = {
    Name = "${var.env}-bastion"
  }
}

# # Tạo private key (RSA 4096 bits)
# resource "tls_private_key" "bastion_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # Tạo key pair trong AWS từ public key
# resource "aws_key_pair" "bastion" {
#   key_name   = "${var.env}-bastion-key"
#   public_key = tls_private_key.bastion_key.public_key_openssh
# }

# # Lưu private key vào file local
# resource "local_file" "bastion_private_key" {
#   content  = tls_private_key.bastion_key.private_key_pem
#   filename = "${path.module}/${var.env}-bastion-key.pem"
# }
