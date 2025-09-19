# ⚠️ Project Challenges

Given the **resource and time constraints**, this project is not yet fully complete. The challenges faced demonstrate that this project required not just **infrastructure expertise** but also a deep dive into **application architecture, cloud-native adaptations, and service orchestration**. Time and resource constraints meant prioritizing core functionality over polish, but the insights gained form a solid foundation for future improvements.

---

## 🔹 Broader Scope Beyond Infrastructure

Provisioning infrastructure (VPC, EKS, RDS, IAM, etc.) was only the starting point. The true complexity lies in adapting application-level requirements—such as schema initialization, Helm charting, and service exposure—to a secure, production-ready cloud environment.

---

## 🔹 Lack of Supabase Experience

This project involved working with **Supabase** for the first time, both in its **self-hosted form** and outside of its **managed SaaS platform**. The learning curve was steep due to:

* Gaps in understanding Supabase internals.
* Unfamiliarity with its dependencies and service structure.
* Minimal guidance available beyond code inspection.

---

## 🔹 Supabase Maturity & Documentation

Supabase is still a **young and evolving project**. This means:

* Frequent changes and evolving best practices.
* Limited official documentation.
* Reliance on reading the source code or community discussions for answers.
* Incomplete or outdated references for Kubernetes-based deployments.

---

## 🔹 Application Exposure on AWS

Making the Kubernetes-hosted application securely accessible on the public Internet required integrating several AWS services:

* **Route53** for domain management.
* **AWS Load Balancer Controller (ALB Controller)** for ingress management.
* **AWS Certificate Manager (ACM)** for TLS/SSL certificates.

Each component requires careful configuration and IAM permissions, making it a non-trivial challenge under time constraints.

---

## 🔹 Migration from Docker Compose to Kubernetes

Supabase is primarily distributed as **Docker containers orchestrated via Docker Compose**. Transitioning this stack to Kubernetes required:

* Breaking apart tightly coupled containers.
* Writing custom Helm manifests and values files.
* Adapting persistent storage and secrets to Kubernetes-native resources.
* Overcoming differences in service discovery and networking models.

---

## 🔹 Lack of Maintained Community Charts

While community Helm charts exist, many are **outdated or abandoned**. This results in:

* The need to fork or write custom charts from scratch.
* Extra testing and validation to ensure compatibility with recent Supabase versions.
* Higher maintenance overhead going forward.
