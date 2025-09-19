module "karpenter" {
  source = "./modules/karpenter"

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  environment       = var.environment
  oidc_provider_arn = var.oidc_provider_arn
  irsa_role_arn     = var.karpenter.irsa_role_arn
  worker_role_arn   = var.karpenter.worker_role_arn

}

module "metrics_server" {
  source = "./modules/metrics-server"
}

module "external_secrets" {
  source = "./modules/external_secrets"

  cluster_name      = var.cluster_name
  environment       = var.environment
  oidc_provider_arn = var.oidc_provider_arn
}

module "alb_controller" {
  source = "./modules/alb-controller"

  cluster_name      = var.cluster_name
  environment       = var.environment
  oidc_provider_arn = var.oidc_provider_arn
  vpc_id            = var.vpc_id

}
