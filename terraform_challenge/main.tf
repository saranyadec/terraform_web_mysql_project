
#create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "app-vpc"
  }
}

#create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

#create public subnet  & Route table
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a NAT Gateway in the public subnet for private subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "nat-gateway"
  }
}

# Create a private subnet for web servers
resource "aws_subnet" "private_web" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private-web-subnet"
  }
}

# Create a private DB subnet for MySQL
resource "aws_subnet" "private_db" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_db_subnet_cidr
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private-db-subnet"
  }
}

# Create a route table for private subnets (use NAT Gateway for internet)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate private web subnet with the route table
resource "aws_route_table_association" "private_web_assoc" {
  subnet_id      = aws_subnet.private_web.id
  route_table_id = aws_route_table.private.id
}

# Associate private db subnet with the route table (only private access)
resource "aws_route_table_association" "private_db_assoc" {
  subnet_id      = aws_subnet.private_db.id
  route_table_id = aws_route_table.private.id
}

# Create a security group for the web server
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow ssh http inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
 
  }

  tags = {
    Name = "web-sg"
  }
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
# }

resource "tls_private_key" "oei-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "oei-key-pair" {
  key_name = "oei-key-pair"
  public_key = tls_private_key.oei-key.public_key_openssh
}

# Create an EC2 instance for the web server
resource "aws_instance" "web" {
#   ami             = "ami-09298640a92b2d12c"
  ami =  "ami-0c2af51e265bd5e0e"
  instance_type   = var.instance_type
  key_name      = aws_key_pair.oei-key-pair.key_name
  subnet_id       = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt-get update
  sudo apt-get install nginx -y
  echo "welcome to terraform web project" > /var/www/html/index.html
  EOF

  tags = {
    Name = "web_instance"
  }

  volume_tags = {
    Name = "web_instance"
  } 
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.app_vpc.id
  name        = "rds-sg"
  description = "Allow rds sg"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id] # Allowed access from web server sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_web.id ,aws_subnet.private_db.id] # Private DB Subnet
  tags = {
    Name = "mysql-rds-subnet-group"
  }
}

# Create an RDS MySQL instance
resource "aws_db_instance" "mysql" {
   allocated_storage      = 20
   max_allocated_storage  = 150
   storage_type           = "gp2"  # General Purpose SSD storage
   identifier             = "myrdsdev"
   engine                 = "MySQL"
   engine_version         = "8.0.35"
   instance_class         = "db.t3.micro"  # Choose an instance class based on your workload
   username               = "admin"  # Replace with your desired username
   password               = "Passw!123"  # Replace with a strong password
   db_name                = "test_mysql_db"  # Name of the database
   backup_retention_period = 7  # Number of days to retain backups
   publicly_accessible    = true  # Make the instance publicly accessible (consider the security implications)
   skip_final_snapshot    = true  # Skip final snapshot when destroying the instance
   vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Associate with the security group
   db_subnet_group_name = aws_db_subnet_group.main.name
   tags = {
     Name = "devrds"  # Tag your instance for easy identification
   }
}