resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-${var.azs[count.index]}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.env}-private-${var.azs[count.index]}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-igw"
  }
}

# Lấy main route table của VPC
data "aws_route_table" "main" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.this.id]
  }

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

resource "aws_ec2_tag" "main_rt_name" {
  resource_id = data.aws_route_table.main.id
  key         = "Name"
  value       = "${var.env}-public-rt"
}

resource "aws_route" "public_internet_access" {
  route_table_id         = data.aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = data.aws_route_table.main.id
}

# Private Route Table
resource "aws_route_table" "private" {
  count             = length(var.azs)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "${var.env}-private-${var.azs[count.index]}-rt"
  }
}

# Gán private route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


# Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.env}-bastion-sg"
  description = "Allow SSH from anywhere to Bastion"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["203.0.0.0/8"]
  }

  egress {
    description     = "MYSQL"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.db_sg.id]
  }

  egress {
    description     = "MYSQL"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "${var.env}-bastion-sg"
  }
}

# Security Group Web Server
resource "aws_security_group" "web_sg" {
  name        = "${var.env}-web-sg"
  description = "Allow HTTP/HTTPS"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["203.0.0.0/8"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["203.0.0.0/8"]
  }

  tags = {
    Name = "${var.env}-web-sg"
  }
}

# Security Group DB
resource "aws_security_group" "db_sg" {
  name        = "${var.env}-db-sg"
  description = "Allow 3306"
  vpc_id      = aws_vpc.this.id

  ingress {
    description              = "MySQL"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_groups          = [aws_security_group.web_sg.id]
  }

  ingress {
    description              = "Bastion"
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    security_groups          = [aws_security_group.bastion_sg.id]
  }


  tags = {
    Name = "${var.env}-db-sg"
  }
}