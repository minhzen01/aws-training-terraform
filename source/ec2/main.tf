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

# resource "aws_instance" "web-application" {
#   ami                         = var.ami_id_web
#   instance_type               = var.instance_type_web 
#   subnet_id                   = var.subnet_id_web
#   associate_public_ip_address = true                  

#   vpc_security_group_ids = var.vpc_security_group_id_web

#   key_name = "minh-quang-key-pair-virginia"

# user_data = <<-EOF
#             #!/bin/bash
#             DB_IP="${aws_instance.mysql.private_ip}"
#             sudo sed -i "s/\\\$host = \".*\";/\\\$host = \\\"$DB_IP\\\";/" /var/www/domain/index.php
#             sudo systemctl restart nginx
#             EOF

#   tags = {
#     Name = "${var.env}-web-application"
#   }
# }


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

# Launch Template web-application
resource "aws_launch_template" "web_app" {
  name_prefix   = "${var.env}-web-app"
  image_id      = var.ami_id_web
  instance_type = var.instance_type_web
  key_name      = "minh-quang-key-pair-virginia"

  vpc_security_group_ids = var.vpc_security_group_id_web

  user_data = base64encode(<<-EOF
              #!/bin/bash
              DB_IP="${aws_instance.mysql.private_ip}"
              sudo sed -i "s/\\\$host = \".*\";/\\\$host = \\\"$DB_IP\\\";/" /var/www/domain/index.php
              sudo systemctl restart nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-web-application"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                      = "${var.env}-web-asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  vpc_zone_identifier       = var.subnet_id_web
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.web_app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.env}-web-application"
    propagate_at_launch = true
  }
}


# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.env}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# ALB 
resource "aws_lb" "web_alb" {
  name               = "${var.env}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.vpc_security_group_id_alb_web
  subnets            = var.subnet_id_web

  enable_deletion_protection = false
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
