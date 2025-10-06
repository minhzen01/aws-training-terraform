variable "ami_id_bastion" {}
variable "ami_id_db" {}
variable "ami_id_web" {}

variable "instance_type_bastion" {}
variable "instance_type_db" {}
variable "instance_type_web" {}

variable "subnet_id_bastion" {}
variable "subnet_id_db" {}
variable "subnet_id_web" {}
variable "subnet_id_alb" {}

variable "vpc_security_group_id_bastion" {}
variable "vpc_security_group_id_db" {}
variable "vpc_security_group_id_web" {}
variable "vpc_security_group_id_alb_web" {}

variable "vpc_id" {}

variable "mysql_domain" {}

variable "env" {}

