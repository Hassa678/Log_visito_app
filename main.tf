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

# ───── app MODULE ─────

module "app" {
  source            = "./modules/app"
  private_subnets   = module.network.private_subnets
  ami_id            = var.ami_id
  app_sg_id         = module.security.app_sg_id
  target_group_arn  = module.load_balancer.target_group_arn
  key_name          = var.key_name
}

# ───── RDS MODULE ─────
module "rds" {
  source      = "./modules/rds"
  db_subnets  = module.network.private_subnets
  db_sg_id    = module.security.db_sg_id
}


module "bastion" {
  source          = "./modules/bastion"
  public_subnets  = module.network.public_subnets
  bastion_sg_id   = module.security.bastion_sg_id
  key_name        = var.key_name
}
