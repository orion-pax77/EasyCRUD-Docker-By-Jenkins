###################################
# Get Default VPC
###################################
data "aws_vpc" "default" {
  default = true
}

###################################
# Get Subnets
###################################
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

###################################
# Security Group for RDS
###################################
resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Allow MySQL access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # ⚠ Open to world (not secure)
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
  name       = "rds-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

###################################
# RDS MySQL Instance
###################################
resource "aws_db_instance" "mariadb" {
  identifier              = "easycrud-mariadb"
  allocated_storage       = 20
  engine                  = "mariadb"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = "easycruddb"
  username                = "admin"
  password                = "redhat123"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
  multi_az                = false

  tags = {
    Name = "EasyCRUD-mariadb"
  }
}
