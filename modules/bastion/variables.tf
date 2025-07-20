variable "public_subnets" {
  type = list(string)
}

variable "bastion_sg_id" {
  type = string
}

variable "key_name" {
  type = string
}
