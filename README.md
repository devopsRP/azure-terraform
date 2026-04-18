<<<<<<< HEAD
# Terraform Azure Infrastructure Deployment 🚀

This project uses **Terraform** to provision and manage Azure infrastructure.
All infrastructure code is version-controlled and pushed to GitHub for collaboration and tracking.

---

## 📌 Overview

This repository contains Terraform configurations to create and manage Azure resources automatically.
It helps in maintaining infrastructure as code (IaC), ensuring consistency, scalability, and repeatability.

---

## ⚙️ Features

* Infrastructure provisioning using Terraform
* Automated Azure resource creation
* Version-controlled infrastructure via GitHub
* Easy to modify and scale resources
* Backup of Terraform state (`.tfstate.backup`)

---

## 🏗️ Resources Created

The Terraform configuration may include (depending on your setup):

* Resource Group
* Virtual Network (VNet)
* Subnets
* Virtual Machines
* Storage Accounts
* Network Interfaces
* Public IPs

---

## 📂 Project Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfstate
├── terraform.tfstate.backup
└── README.md
```

---

## 🔧 Prerequisites

Make sure you have the following installed:

* Terraform
* Azure CLI
* Git

---

## 🔑 Authentication

Login to Azure before running Terraform:

```bash
az login
```

---

## 🚀 Usage

1. Clone the repository:

```bash
git clone https://github.com/devopsRP/Terraform-Azure-infra.git
cd Terraform-Azure-infra
```

2. Initialize Terraform:

```bash
terraform init
```

3. Validate configuration:

```bash
terraform validate
```

4. Plan the deployment:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

---

## 🔄 State Management

* `terraform.tfstate` → Current infrastructure state
* `terraform.tfstate.backup` → Backup of previous state

⚠️ **Note:** Avoid pushing state files to public repositories. Use remote backends (like Azure Storage) for better security.

---

## 📌 Version Control

All Terraform configurations are pushed to GitHub to:

* Track changes
* Collaborate with team members
* Maintain infrastructure history

---

## ⚠️ Best Practices

* Do not commit sensitive data
* Use `.gitignore` for state files
* Use remote backend for production
* Keep variables in separate files

---

## 📞 Support

If you face any issues, feel free to raise an issue or contribute to the repository.

---


=======
>>>>>>> a186145c534c43114bbe448699d2ec36d13c207e

