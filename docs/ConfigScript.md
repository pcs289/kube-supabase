# 📘 Guidelines for `config.sh`

This document provides instructions and usage examples for the `config.sh` script, which automates provisioning, managing, and cleaning up infrastructure and applications using **Terraform**, **AWS**, **Helm**, and **Kubernetes**.

---

## 🚀 Overview

The script helps with:

* Managing Terraform workflows (`init`, `plan`, `apply`, `destroy`).
* Deploying Kubernetes applications with Helm.
* Managing AWS EKS clusters and kubeconfig.
* Encrypting and decrypting secrets using AWS KMS.
* Cleaning up stuck cluster resources.

Default environment: **`production`**

---

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

---

## ⚙️ Commands

### 1. Terraform Workflow

* **Format code**

  ```bash
  ./config.sh fmt
  ```

  Formats all Terraform files.

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
  ./config.sh import <resource_address>
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

---

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

---

### 3. Kubernetes & Helm

* **Update kubeconfig**

  ```bash
  ./config.sh kubeconfig
  ```

* **Template Helm chart**

  ```bash
  ./config.sh template
  ```

* **Deploy application**

  ```bash
  ./config.sh deploy
  ```

---

### 4. Cluster Cleanup

* **Nuke cluster resources**

  ```bash
  ./config.sh cleanup
  ```

  Cleans up:

  * Karpenter CRDs & resources
  * Stuck nodes
  * Leftover resources in non-system namespaces

---

### 5. Secrets Management

* **Encrypt secret with AWS KMS**

  ```bash
  ./config.sh encrypt
  ```

  Prompts for secret input → Base64 encodes → Encrypts with AWS KMS key `production-secret-store-key`.

* **Decrypt secret**

  ```bash
  ./config.sh decrypt
  ```

  Prompts for encrypted secret input → Decrypts with AWS KMS key → Decodes Base64.

---

## ❌ Error Handling

* If a required tool is missing, the script exits with installation instructions.
* Unknown commands will produce:

  ```
  ❌ Unknown Command: <COMMAND>
  ```

---

## ✅ Best Practices

* Always run `./config.sh prerequisites` before working in a new environment.
* Use `plan` before `apply` or `destroy` to review changes.
* Keep AWS credentials configured with the correct profile.
* Use `cleanup` if resources get stuck (especially after partial deletions).
* Encrypt secrets before committing them anywhere.

---

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

5. **Tear down when done**

   ```bash
   ./config.sh tear-down
   ```

---

## 🔑 Default Configurations

* Environment: `production`
* Cluster name: `production-cluster`
* App name: `supabase`
* Namespace: `supabase`
* Key alias: `production-secret-store-key`
* Helm chart path: `manifests/environments/production/supabase`
