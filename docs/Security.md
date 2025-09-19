# Security

## S3 Security

- Public access is blocked (aws_s3_bucket_public_access_block).

- Server-side encryption is enabled on S3 buckets.

- Bucket versioning is enabled for recovery and immutability.

- Ownership controls are configured to enforce account-level ownership.

## Encryption & Secrets

- AWS KMS is used for encryption of sensitive resources.

- Secrets are encrypted with KMS (aws_kms_secrets).

- AWS Secrets Manager securely stores secrets instead of hardcoding them.

## EKS (Kubernetes)

- EKS cluster provisioned with IAM authentication and RBAC support.

- Fargate profiles provide isolation by running workloads without managing EC2 nodes.

- EKS addons (e.g., CoreDNS, VPC CNI, kube-proxy) are managed to stay secure and updated.

- Pod Identity associations allow fine-grained IAM roles at pod level.

- IAM OIDC provider is configured for secure service account integration with IAM.


## IAM

- Custom IAM policies exist to enforce specific access rules following least privilege principle.

- IAM OpenID Connect provider enables secure role assumption for Kubernetes workloads.

## Database (RDS)

- RDS instances are provisioned with encryption support at rest and TLS in transit.

## Network Security

- Network ACLs are defined to control subnet-level ingress/egress.

- Security groups are used to restrict inbound and outbound traffic at the instance/pod level.

- NAT Gateway ensures private resources can reach the internet without being directly exposed.
