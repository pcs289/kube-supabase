# 📘 Configuration Script

This document provides instructions and usage examples for the `config.sh` script, which automates provisioning, managing, and cleaning up infrastructure and applications using **Terraform**, **AWS**, **Helm**, and **Kubernetes**.

## 🚀 Overview

The script helps with:

* Managing Terraform workflows (`fmt`, `init`, `validate`, `plan`, `apply`, `destroy`).
* Provisioning and tearing down full environments.
* Deploying Kubernetes applications with Helm.
* Managing AWS EKS clusters and kubeconfig.
* Encrypting and decrypting secrets using AWS KMS.
* Debugging and smoke testing applications.
* Cleaning up stuck cluster resources.

Default environment: **`production`**

## 🛠️ Prerequisites

Before running the script, ensure the following tools are installed:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [terraform-docs](https://terraform-docs.io/user-guide/installation/)
* [Helm](https://helm.sh/docs/intro/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

Run the following to check prerequisites:

```bash
./config.sh prerequisites
```

**Also make sure to:**

#### Configure Terraform Values
1. **Rename** `terraform.tfvars.example` as `terraform.tfvars` in `terraform/environments/production/` folder
2. **Edit** it with your own values

#### Configure Manifests values

- **Configure** files under `manifests/environments/production` folder

## ⚙️ Commands

### 1. Terraform Workflow

* **Format code**

  ```bash
  ./config.sh fmt
  ```

* **Initialize environment**

  ```bash
  ./config.sh init
  ```

* **Validate code**

  ```bash
  ./config.sh validate
  ```

* **Plan changes**

  ```bash
  ./config.sh plan
  ./config.sh plan <target>
  ```

* **Import resource**

  ```bash
  ./config.sh import <resource_address> <import_address>
  ```

* **Apply changes**

  ```bash
  ./config.sh apply
  ./config.sh apply <target>
  ```

* **Destroy resources**

  ```bash
  ./config.sh destroy
  ./config.sh destroy <target>
  ```

### 2. Provisioning & Tear-down

* **Provision all modules**

  ```bash
  ./config.sh provision
  ```

  Runs in order: VPC → EKS → Helm Base → Secret Store → Bucket → RDS.

* **Tear down modules**

  ```bash
  ./config.sh tear-down
  ```

  Runs in reverse order: RDS → Bucket → Secret Store → Helm Base → EKS → VPC.

### 3. Kubernetes & Helm

* **Update kubeconfig**

  ```bash
  ./config.sh kubeconfig
  ```

* **Template Helm chart**

  ```bash
  ./config.sh template
  ```

* **Deploy application(s)**

  ```bash
  ./config.sh deploy
  ```

  Deploys Supabase and HAProxy manifests into the cluster.

* **Debug cluster**

  ```bash
  ./config.sh debug
  ```

  Opens an ephemeral `alpine` pod with `psql` client pre-installed for live debugging.

### 4. Cluster Cleanup

* **Clean up cluster resources**

  ```bash
  ./config.sh cleanup
  ```

  Cleans up:

  * Karpenter CRDs & resources
  * Stuck nodes
  * Leftover resources in non-system namespaces

### 5. Secrets Management

* **Encrypt secret with AWS KMS**

  ```bash
  ./config.sh encrypt
  ```

* **Decrypt secret**

  ```bash
  ./config.sh decrypt
  ```

### 6. Application Testing

* **Smoke test Supabase**

  ```bash
  ./config.sh smoke
  ```

  Retrieves the `anonKey` from AWS Secrets Manager and runs a test request against Supabase’s REST API endpoint.

## ❌ Error Handling

* If a required tool is missing, the script exits with installation instructions.
* Unknown commands will produce:

  ```
  ❌ Unknown Command: <COMMAND>
  ```

## ✅ Best Practices

* Always run `./config.sh prerequisites` before working in a new environment.
* Use `plan` before `apply` or `destroy` to review changes.
* Keep AWS credentials configured with the correct profile.
* Use `cleanup` if resources get stuck (especially after partial deletions).
* Use `smoke` to validate app endpoints after deployment.
* Encrypt secrets before committing them anywhere.

## 📖 Example Workflow

1. **Check tools**

   ```bash
   ./config.sh prerequisites
   ```

2. **Provision infrastructure**

   ```bash
   ./config.sh provision
   ```

3. **Update kubeconfig**

   ```bash
   ./config.sh kubeconfig
   ```

4. **Deploy application**

   ```bash
   ./config.sh deploy
   ```

5. **Smoke test app**

   ```bash
   ./config.sh smoke
   ```

6. **Tear down when done**

   ```bash
   ./config.sh tear-down
   ```

## 🔑 Default Configurations

* Environment: `production`
* Cluster name: `production-cluster`
* App name: `supabase`
* Namespace: `supabase`
* Key alias: `production-secret-store-key`
* Secret ID Name: `production-supabase-jwt`
* Helm chart path: `manifests/environments/production/supabase`
