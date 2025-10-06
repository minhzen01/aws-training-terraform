variable "env" {}

variable "cidr_block" {}
variable "azs" {}

variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}

variable "ami_id_bastion" {}
variable "ami_id_db" {}
variable "ami_id_web" {}

variable "instance_type_bastion" {}
variable "instance_type_db" {}
variable "instance_type_web" {}

variable "mysql_domain" {}
variable "root_domain" {}
