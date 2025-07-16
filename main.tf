terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "log-visitor-app-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "log-visitor-app-terraform-locks"
  }
}

provider "aws" {
  region = "us-east-1"
}

# ───── NETWORK MODULE ─────
module "network" {
  source = "./modules/network"
}

# ───── SECURITY GROUPS MODULE ─────
module "security" {
  source  = "./modules/security"
  vpc_id  = module.network.vpc_id
}

# ───── LOAD BALANCER MODULE ─────
module "load_balancer" {
  source          = "./modules/load_balancer"
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  alb_sg_id       = module.security.alb_sg_id
  app_sg_id       = module.security.app_sg_id
}

# ───── AUTOSCALING MODULE ─────
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "autoscaling" {
  source            = "./modules/autoscaling"
  private_subnets   = module.network.private_subnets
  ami_id            = data.aws_ami.amazon_linux.id
  app_sg_id         = module.security.app_sg_id
  target_group_arn  = module.load_balancer.target_group_arn
}

# ───── RDS MODULE ─────
module "rds" {
  source      = "./modules/rds"
  db_subnets  = module.network.private_subnets
  db_sg_id    = module.security.db_sg_id
}
