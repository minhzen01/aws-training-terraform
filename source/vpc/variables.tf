variable "env" {}

variable "cidr_block" {
  description = "CIDR VPC"
  type        = string
}

variable "azs" {
  description = "AZ List"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR Public Subnet List"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR Private Subnet List"
  type        = list(string)
}
