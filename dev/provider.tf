terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "us-east-1"
}

# resource "aws_instance" "app_server" {
#   ami           = "ami-0360c520857e3138f"
#   instance_type = "t2.micro"
#   subnet_id              = "subnet-76200d5a"
#   vpc_security_group_ids = ["sg-0d8c6c74bb2d34b86"]

#   tags = {
#     Name = "learn-terraform"
#   }
# }
