###############################################################################
# EKS Cluster Addons
###############################################################################

locals {
  addons = [
    "coredns",
    "aws-ebs-csi-driver",
    "eks-pod-identity-agent",
    "kube-proxy",
    "vpc-cni"
  ]

  addon_configs = {
    coredns = jsonencode({
      computeType  = "Fargate"
      replicaCount = 1
      resources = {
        limits = {
          cpu    = "0.5"
          memory = "512M"
        }
        requests = {
          cpu    = "0.25"
          memory = "256M"
        }
      }
    })

    aws-ebs-csi-driver = jsonencode({
      controller = {
        replicaCount = 1
        resources = {
          limits = {
            cpu    = "0.5"
            memory = "512M"
          }
          requests = {
            cpu    = "0.25"
            memory = "256M"
          }
        }
      }
      sidecars = {
        snapshotter = {
          forceEnable : false
        }
      }
    })
  }

  addon_roles = {
    aws-ebs-csi-driver = aws_iam_role.ebs_csi.arn
  }

  ebs_sa = "ebs-csi-controller-sa"
}

resource "aws_eks_addon" "addon" {
  for_each = toset(local.addons)

  cluster_name = aws_eks_cluster.main.name
  addon_name   = each.value

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  service_account_role_arn = lookup(local.addon_roles, each.value, null)

  configuration_values = lookup(local.addon_configs, each.value, null)

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_fargate_profile.this,
  ]

  tags = {
    Name        = "${var.cluster_name}-addon-${each.value}"
    Environment = var.environment
  }
}

###############################################################################
# IAM role for AWS EBS CSI Driver
###############################################################################

resource "aws_iam_role" "ebs_csi" {
  name        = "${var.cluster_name}-ebs-csi"
  description = "IAM role for the aws-ebs-csi-driver service account inside the cluster"

  assume_role_policy = data.aws_iam_policy_document.assume_pod_identity.json

  tags = {
    Name        = "${var.cluster_name}-ebs-csi"
    Environment = var.environment
  }
}

// Attach AmazonEBSCSIDriverPolicy policy to ebs_csi Role
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}

// Deploy StorageClass to cluster
resource "kubectl_manifest" "ebs_csi_storage_class" {
  yaml_body = file("${path.module}/assets/ebs_csi_storage_class.yaml")

  depends_on = [
    aws_eks_addon.addon["aws-ebs-csi-driver"]
  ]
}
