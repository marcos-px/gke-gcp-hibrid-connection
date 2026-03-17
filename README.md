# GKE GCP Hybrid Connection

This repository contains the Infrastructure as Code (IaC) and configuration management to provision a production-ready, hybrid architecture in Google Cloud Platform (GCP). The architecture encompasses a **Shared VPC** design, a **Private GKE Cluster** connected to an on-premises network via **HA VPN**, **Cloud SQL**, IAM configurations, and **Workload Identity Federation (WIF)**. 

## 🏗 Architecture Overview

The infrastructure relies on the **Shared VPC** pattern with specialized Service and Host projects to ensure network isolation and centralized billing/routing.

### Core Components:
- **Bootstrap (`/bootstrap`)**: Lays the foundation by creating the GCP Folders, Host Projects, and Service Projects for different environments (dev, stg, prd). It also configures Workload Identity Federation (WIF) and Artifact Registry.
- **Networking (`/modules/networking`)**: provisions the Shared VPC, subnets with secondary CIDR ranges for GKE (pods, services, masters), and establishes an HA VPN connection to the on-premise network.
- **Compute (`/modules/gke`)**: Deploys a highly available, regional **Private GKE Cluster** integrated with the Shared VPC.
- **Database (`/modules/database`)**: Provisions **Cloud SQL**, utilizing Private Service Access for secure internal connectivity.
- **IAM (`/modules/iam`)**: Configures precise Service Accounts following the principle of least privilege, specific to GKE Nodes and Applications.
- **Observability (`/modules/observability`)**: Builds monitoring mechanisms including Uptime Checks and Notification Channels for the environment.
- **Ansible (`/ansible`)**: Contains playbooks to verify the provisioned infrastructure and rotate operational secrets.

## 📁 Repository Structure

```text
.
├── ansible/
│   ├── inventory/              # Ansible dynamic/static inventory
│   └── playbooks/
│       ├── rotate_secrets.yml  # Secret rotation playbook
│       ├── site.yml            # Main playbook (if applicable)
│       └── verify_infra.yml    # Validates GKE pods, Cloud SQL states, and Secrets
├── bootstrap/                  # Foundation Layer
│   ├── main.tf                 # Projects and APIs
│   ├── wif.tf                  # Workload Identity Federation setup
│   └── artifact_registry.tf    # Docker/Helm repository configurations
├── environments/
│   └── dev/                    # Development Environment setup
│       ├── main.tf             # Module invocations
│       ├── variables.tf
│       └── terraform.tfvars.example
└── modules/                    # Reusable Terraform Modules
    ├── database/
    ├── gke/
    ├── iam/
    ├── networking/
    └── observability/
```

## 📋 Prerequisites

To deploy this environment, you will need:
1. **Google Cloud SDK (`gcloud`)** installed and authenticated.
2. **Terraform** (>= 1.5.0) installed.
3. **Ansible** installed for infrastructure verification.
4. Appropriate permissions in a GCP Organization:
    - `roles/resourcemanager.organizationAdmin`
    - `roles/billing.admin`
5. An existing Google Cloud Organization ID and a Billing Account ID.

## 🚀 Deployment Guide

The deployment happens in two key stages:

### 1. Bootstrap the Foundation

Navigate to the `bootstrap` directory and initialize Terraform. This step provisions the Folders, Host/Service Projects, enables necessary Google Cloud APIs, and configures Artifact Registry and WIF.

```bash
cd bootstrap
terraform init
# Review the plan
terraform plan
# Apply the configuration
terraform apply
```

### 2. Deploy the Environment (e.g., Development)

Once the foundation is bootstrapped, navigate to the environment you wish to provision. The environment configuration reads the remote state from the bootstrap stage to identify project IDs.

```bash
cd environments/dev
# Duplicate the example variable file
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars` with your specific network CIDRs, VPN Pre-Shared Key, BGP ASN, and cluster information.

```bash
terraform init
terraform plan
terraform apply
```

## 🧪 Validating Infrastructure

After the infrastructure has been successfully provisioned by Terraform, you can use Ansible to verify that the core components (GKE, Cloud SQL, Secret Manager) are fully operational and initialized correctly.

```bash
cd ansible
ansible-playbook -i inventory/ playbooks/verify_infra.yml
```

This playbook will assure that:
- GKE nodes are registered and `kube-system` pods are running smoothly.
- The Cloud SQL instance is in a `RUNNABLE` state.
- Necessary secrets (like `db-password`) are securely stored properly in GCP Secret Manager.

## 🧹 Teardown

To tear down the infrastructure and avoid incurring further costs:

```bash
# First, destroy the environment
cd environments/dev
terraform destroy

# Secondly, destroy the bootstrap configuration (Warning: this deletes the GCP projects)
cd ../../bootstrap
terraform destroy
```
