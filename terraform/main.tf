provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr        = var.vpc_cidr
  cluster_name    = var.cluster_name
  aws_region      = var.aws_region
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  vpc_id         = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}

module "ecr" {
  source = "./modules/ecr"
  
  repository_names = ["url-shortener-frontend", "url-shortener-backend"]
} 