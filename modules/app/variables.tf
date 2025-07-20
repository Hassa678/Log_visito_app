
variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for EC2 instances"
  type        = string
}