variable "cluster_name" {
  type = string
}
variable "cluster_cidr" {
  type    = string
  default = "10.100.0.0/16"
}
variable "eks_access_cidrs" {
  type        = list(string)
  description = "List of IPs with access to EKS Control Plane"
}
variable "eks_subnets" {
  type        = list(string)
  description = "Subnets where Amazon EKS can place Elastic Network Interfaces. These cannot be changed after cluster creation"
}
variable "eks_version" {
  type        = string
  description = "EKS Version"
  default     = "1.33"
}
variable "environment" {
  type = string
}
variable "fargate_profiles" {
  type = map(object({
    name      = optional(string)
    selectors = list(object({ namespace = string }))
  }))
  default = {
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube_system = {
      name = "kube-system"
      selectors = [
        { namespace = "kube-system" },
      ]
    }
  }
}
variable "private_nodes" {
  type = map(object({
    ami_type       = string
    capacity_type  = string
    disk_size      = number
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
  }))
  default = {}
}
variable "public_nodes" {
  type = map(object({
    ami_type       = string
    capacity_type  = string
    disk_size      = number
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
  }))
  default = {}
}
variable "public_subnets" {
  type        = list(string)
  description = "Subnets where Amazon EKS can place Load Balancers for Ingress"
}
variable "private_subnets" {
  type        = list(string)
  description = "Subnets where Amazon EKS can place Worker Nodes"
}
variable "vpc_id" {
  type = string
}
