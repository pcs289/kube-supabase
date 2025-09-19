////////////////////////////////////////////////
/// First apply these 3 modules sequentially
///
/// `terraform apply -target=module.vpc`
/// `terraform apply -target=module.eks`
/// `terraform apply -target=module.helm_base`
///


// 1. Bootstrap Networking
module "vpc" {
  source = "../../modules/vpc"

  allow_ssh_cidrs    = var.allow_ssh_cidrs
  eks_cluster_name   = var.cluster_name
  environment        = var.environment
  single_nat_gateway = var.vpc_single_nat
  vpc_cidr_block     = var.vpc_cidr_block

}


// 2. Bootstrap EKS Cluster
module "eks" {
  source = "../../modules/eks"

  cluster_name     = var.cluster_name
  cluster_cidr     = var.cluster_cidr
  eks_access_cidrs = concat(var.allow_ssh_cidrs, ["${module.vpc.nat_gw_ip}/32"])
  eks_subnets      = module.vpc.eks_subnets
  eks_version      = var.cluster_version
  environment      = var.environment
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  vpc_id           = module.vpc.vpc_id

}

// 3. Install Base Helm packages: Karpenter, MetricsServer, ExternalSecret, ALBController
module "helm_base" {
  source = "../../modules/helm_base"

  cluster_name      = var.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca_data   = module.eks.cluster_ca_data
  environment       = var.environment
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  karpenter         = module.eks.karpenter_roles
  vpc_id            = module.vpc.vpc_id

}
