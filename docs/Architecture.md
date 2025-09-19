# 🏗️ System Architecture

![Architecture Diagram](img/Architecture.png)

This project provisions a **production-ready Supabase deployment on AWS**, leveraging Terraform for infrastructure orchestration and Kubernetes (EKS) for containerized workloads. The architecture balances security, scalability, and modularity by combining managed AWS services with Kubernetes-native deployments.

---

## 🏛️ Architectural Components

* **Networking**

  * Dedicated VPC with private and public subnets.
  * NAT Gateway ensures private subnets can reach the internet without direct exposure.
  * Internet Gateway for ingress via load balancers.
  * Security Groups and Network ACLs enforce controlled ingress/egress.

* **Compute**

  * **Amazon EKS Cluster** as the control plane.
  * **EKS Fargate Profiles** for pod-level isolation (serverless compute model) of critical workloads.
  * **Managed EKS Addons** (CoreDNS, VPC CNI, kube-proxy) for secure, up-to-date cluster services.

* **Identity & Access**

  * **IAM OIDC Provider** enables IAM roles for Kubernetes service accounts.
  * Fine-grained IAM policies attached to EKS pods (`aws_eks_pod_identity_association`).

* **Storage & Databases**

  * **RDS PostgreSQL instance** (deployed in private subnets, encrypted with KMS).
  * **S3 Buckets** for object storage, configured with:

    * Public access blocks,
    * Server-side encryption,
    * Versioning,
    * Ownership controls.

* **Secrets & Encryption**

  * **AWS KMS Keys & Aliases** for encryption at rest.
  * **AWS Secrets Manager** for centralized, encrypted secret storage.
  * Integration with Kubernetes via Helm-based secret management.

* **Application Layer**

  * **Supabase services** deployed with Helm charts inside EKS.
  * Application namespace isolation (`supabase`).
  * Ingress handled by **AWS Load Balancer Controller**, integrated with:

    * **Route53** for DNS,
    * **AWS Certificate Manager (ACM)** for TLS certificates.

* **Monitoring & Events**

  * **CloudWatch Event Rules** for operational insights.
  * Integration points available for log shipping and auditing.

---

## 🌱 Bootstrapping the Environment

The first environment, `production`, is bootstrapped as follows:

1. **Prepare Environment Variables**

   Edit variables at:

   ```
   terraform/environments/production/terraform.tfvars.example
   ```

   Rename the file to:

   ```
   terraform.tfvars
   ```

2. **Create Spot EC2 Service-Linked Role (if using Spot Instances)**

   This step must be executed once per AWS account:

   ```bash
   aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
   ```

3. **Provision Infrastructure**

   Use the helper script to provision Terraform-managed resources:

   ```bash
   ./config.sh provision
   ```

---

## 🔑 Secret Management

Secrets are managed using **AWS KMS** and **AWS Secrets Manager**:

1. Apply the `secret-store` module with empty secrets (i.e. `var.secrets = {}`).
2. Encrypt secrets with the generated **KMS key alias**:

   ```bash
   ./config.sh encrypt
   ```
3. Add encrypted secrets into `terraform.tfvars`.
```
secrets = {
        SUPABASE_DB = "AQIAEDJIDJIEJEIJ"
}
```
4. Re-apply the module with populated `var.secrets`.

   * Secrets will be created in Secrets Manager with the environment prefix, e.g.: `production-supabase-db`

This ensures that **sensitive credentials** (RDS passwords, API keys) are encrypted at rest and only accessible to authorized IAM roles or Kubernetes workloads.

---

## ☸️ Kubernetes Access

Once the cluster is provisioned:

1. **Update kubeconfig & verify connectivity**

   ```bash
   ./config.sh kubeconfig
   ```

2. **Cluster Management Tools**

   * [K9s](https://k9scli.io/) — terminal-based TUI for Kubernetes.
   * [OpenLens](https://github.com/MuhammedKalkan/OpenLens) — graphical interface for managing workloads.
