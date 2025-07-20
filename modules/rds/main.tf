variable "db_subnets" { type = list(string) }
variable "db_sg_id" {}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnets
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "rds-db-password-new-1"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = "YourSecurePasswordHere" }) # Replace securely in prod
}

resource "aws_db_instance" "app_db" {
  identifier              = "app-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "appdb"
  username                = "admin"
  password                = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string).password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [var.db_sg_id]

  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false

  tags = {
    Name = "app-db"
  }
}
