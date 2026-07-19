# Terraform Azure Modules - Basic Practice

## 📖 Overview

This repository demonstrates how to build Azure infrastructure using **Terraform Modules**.

Instead of writing all resources in a single file, every Azure resource is separated into its own reusable module.

Current modules:

- Azure Resource Group
- Azure Virtual Network
- Azure Subnet

The project also contains an **environment folder** (`dev`) which calls these modules and provides the required values.

---

# Why Terraform Modules?

Imagine you need to create the same infrastructure for:

- Development
- Testing
- Production

Without modules, you would copy and paste hundreds of lines of Terraform code.

This leads to:

- Duplicate code
- Difficult maintenance
- Higher chance of mistakes

Terraform Modules solve this problem.

A module is simply a reusable Terraform package.

Write once.

Use many times.

---

# Project Structure

```
module_basic/
│
├── azurerm_ResourceGroup/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── azurerm_Virtual_network/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── azurerm_subnet/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── environments/
    └── dev/
        ├── backend.tf
        ├── provider.tf
        ├── variables.tf
        ├── terraform.tfvars
        └── main.tf
```

---

# Understanding Each Folder

## azurerm_ResourceGroup

Creates an Azure Resource Group.

Input:

- Resource Group Name
- Location

Output:

- Resource Group Name
- Resource Group ID

---

## azurerm_Virtual_network

Creates a Virtual Network.

Input:

- VNet Name
- Address Space
- Resource Group Name
- Location

Output:

- VNet Name
- VNet ID

---

## azurerm_subnet

Creates one or multiple subnets.

Input:

- VNet Name
- Resource Group Name
- Address Prefixes

Output:

- Subnet IDs
- Subnet Names

---

## environments/dev

This is the root module.

It does **not** create Azure resources directly.

Instead, it calls the reusable modules.

Example:

```
Resource Group Module
        ↓
Virtual Network Module
        ↓
Subnet Module
```

This is where all values are passed.

---

# Why Multiple .tf Files?

Terraform does not care about file names.

Terraform loads every `.tf` file inside a folder.

We split files only to keep the project clean and easy to understand.

---

## main.tf

Contains actual resource creation.

Example:

```
resource "azurerm_resource_group" ...
```

Think of it as:

> What should Terraform create?

---

## variables.tf

Contains all input variables.

Example:

```
variable "location" {}

variable "rg_name" {}
```

Think of it as:

> What information is required?

---

## outputs.tf

Returns useful information after deployment.

Example:

```
output "resource_group_name" {}
```

Think of it as:

> What information should other modules use?

---

## provider.tf

Defines which cloud provider Terraform should use.

Example:

```
provider "azurerm" {
    features {}
}
```

Think of it as:

> Which cloud are we deploying to?

---

## backend.tf

Stores Terraform State remotely.

Examples:

- Azure Storage Account
- S3 Bucket
- Terraform Cloud

Think of it as:

> Where should Terraform save its state?

---

## terraform.tfvars

Stores actual values.

Example:

```
rg_name = "demo-rg"

location = "Central India"

vnet_name = "demo-vnet"
```

Think of it as:

> Real values for variables.

---

# Terraform Workflow

```
terraform init

↓

terraform validate

↓

terraform plan

↓

terraform apply

↓

terraform destroy
```

---

# Module Flow

```
terraform.tfvars
        │
        ▼
variables.tf
        │
        ▼
main.tf
        │
        ▼
Azure Resource Created
        │
        ▼
outputs.tf
```

---

# Module Dependency

```
Resource Group
      │
      ▼
Virtual Network
      │
      ▼
Subnet
```

The Virtual Network depends on the Resource Group.

The Subnet depends on the Virtual Network.

Terraform automatically builds the dependency graph.

---

# How to Create a New Module

Step 1

Create a new folder.

```
azurerm_storage_account/
```

Step 2

Create three files.

```
main.tf

variables.tf

outputs.tf
```

Step 3

Write the resource in `main.tf`.

Step 4

Declare inputs in `variables.tf`.

Step 5

Export useful values in `outputs.tf`.

Step 6

Call the module from the environment folder.

```
module "storage_account" {
    source = "../../azurerm_storage_account"

    ...
}
```

---

# Best Practices

✅ One resource type per module

✅ Keep modules reusable

✅ Never hardcode names

✅ Use variables for inputs

✅ Export useful outputs

✅ Keep environments separate

✅ Store state remotely

✅ Follow consistent naming conventions

---

# Learning Goal

This project helps understand:

- Terraform Modules
- Reusable Infrastructure
- Input Variables
- Outputs
- Module Dependencies
- Azure Infrastructure as Code (IaC)
- Environment Separation (Dev/Test/Prod)
- Terraform Project Structure

---

# Future Improvements

- Network Security Group Module
- Public IP Module
- Network Interface Module
- Virtual Machine Module
- Storage Account Module
- Key Vault Module
- App Service Module
- SQL Database Module
- Load Balancer Module
- Application Gateway Module
- Remote Backend with Azure Storage