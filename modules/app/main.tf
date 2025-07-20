variable "private_subnets" {
  type = list(string)
}


variable "app_sg_id" {}

variable "target_group_arn" {}

resource "aws_instance" "app" {
  count         = 2  # Adjust number of instances as needed
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = element(var.private_subnets, count.index)
  vpc_security_group_ids = [var.app_sg_id]
  key_name      = var.key_name
  associate_public_ip_address = false

  tags = {
    Name = "app-instance-${count.index}"
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  count            = length(aws_instance.app)
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app[count.index].id
  port             = 5000
}
