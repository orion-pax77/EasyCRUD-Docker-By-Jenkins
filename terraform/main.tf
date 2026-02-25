###################################
# Random Suffix (Avoid Duplicate Errors)
###################################
resource "random_id" "suffix" {
  byte_length = 2
}

###################################
# Get Default VPC
###################################
data "aws_vpc" "default" {
  default = true
}

###################################
# Get Default Subnets
###################################
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

###################################
# DB Password Variable (Secure)
###################################
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

###################################
# Security Group for RDS (Secure)
###################################
resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg-${random_id.suffix.hex}"
  description = "Allow MySQL access from current IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]  # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################################
# DB Subnet Group
###################################
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-${random_id.suffix.hex}"
  subnet_ids = data.aws_subnets.default.ids
}

###################################
# RDS MariaDB Instance (Free Tier Safe)
###################################
resource "aws_db_instance" "mariadb" {
  identifier              = "easycrud-${random_id.suffix.hex}"
  allocated_storage       = 20
  max_allocated_storage   = 20

  engine                  = "mariadb"
  engine_version          = "10.6.14"

  instance_class          = "db.t3.micro"
  storage_type            = "gp2"

  db_name                 = "easycruddb"
  username                = "admin"
  password                = var.db_password

  db_subnet_group_name    = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  publicly_accessible     = true
  multi_az                = false
  skip_final_snapshot     = true
  deletion_protection     = false

  backup_retention_period = 0
  performance_insights_enabled = false
  auto_minor_version_upgrade    = true

  tags = {
    Name = "EasyCRUD-mariadb"
  }
}
