output "ec2_id_bastion" {
  value = aws_instance.bastion.id
}

output "ec2_id_db" {
  value = aws_instance.mysql.id
}

output "ec2_mysql" {
  value = aws_instance.mysql
}