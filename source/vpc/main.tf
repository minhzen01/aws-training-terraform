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

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "${var.env}-public-rt"
  }
}

# Gán public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
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

  tags = {
    Name = "${var.env}-bastion-sg"
  }
}

# Security Group Private EC2
resource "aws_security_group" "private_sg" {
  name        = "${var.env}-private-sg"
  description = "Allow SSH only from Bastion Host"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "SSH from Bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["203.0.0.0/8"]
  }

  tags = {
    Name = "${var.env}-private-sg"
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