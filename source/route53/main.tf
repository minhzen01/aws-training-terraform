resource "aws_route53_zone" "private" {
  name = var.root_domain

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "mysql_record" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.mysql_domain
  type    = "A"
  ttl     = 300
  records = [var.mysql_private_ip]
#   records = [aws_instance.mysql.private_ip]
}