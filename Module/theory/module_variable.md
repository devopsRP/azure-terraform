# 📚 Terraform Variables 

> If you understand this document, you will never be confused about Terraform variables again.

---

# The Biggest Confusion

Most beginners ask:

> Why do we write variables in both the Root Module and the Child Module?

Example:

```
environments/dev/variables.tf
```

and

```
azurerm_ResourceGroup/variables.tf
```

Both contain

```
variable "rg_name" {}
```

Why?

Isn't one enough?

The answer is **NO**.

Because both modules have different responsibilities.

---

# First Understand Terraform Modules

Terraform has two kinds of modules.

```
Root Module

Child Module
```

Think like this.

```
You
 │
 │
 ▼
Root Module
 │
 │ gives instructions
 ▼
Child Module
 │
 │ creates Azure Resource
 ▼
Azure
```

The Root Module is the manager.

The Child Module is the worker.

---

# Root Module

Example

```
environments/dev/
```

Purpose

- Reads values
- Calls modules
- Connects modules
- Passes data

It usually does NOT create Azure resources directly.

Example

```
module "resource_group" {

    source = "../../azurerm_ResourceGroup"

    rg_name  = var.rg_name
    location = var.location

}
```

Notice something.

The root module is NOT creating a resource.

It is only passing values.

---

# Child Module

Example

```
azurerm_ResourceGroup/
```

Purpose

Actually creates Azure resources.

Example

```
resource "azurerm_resource_group" "rg" {

    name     = var.rg_name
    location = var.location

}
```

Here the variable is finally used.

---

# Complete Data Flow

```
terraform.tfvars

        │

        ▼

Root Variables

variables.tf

        │

        ▼

main.tf

module "resource_group"

        │

        ▼

Child Variables

variables.tf

        │

        ▼

main.tf

resource "azurerm_resource_group"

        │

        ▼

Azure
```

Always remember this flow.

---

# Why Declare Variable in Root Module?

Example

```
variable "rg_name" {}
```

Reason

The Root Module needs a place to receive data.

Think of it as

"I am expecting a Resource Group Name."

Without this declaration Terraform doesn't know what

```
var.rg_name
```

means.

---

# Why Declare Variable in Child Module?

Example

```
variable "rg_name" {}
```

Reason

The Child Module also needs a place to receive data.

Remember

Modules are isolated.

A Child Module cannot directly access variables from the Root Module.

So it needs its own input variables.

Think of it as

"I am waiting for someone to send me a Resource Group Name."

---

# Real Life Example

Imagine a pizza shop.

Customer

↓

Manager

↓

Chef

Customer says

```
Large Cheese Pizza
```

Manager writes the order.

Chef receives the order.

Manager and Chef BOTH know the order.

Why?

Because information must be transferred.

Terraform variables work exactly like this.

```
terraform.tfvars

↓

Root Module

↓

Child Module

↓

Azure
```

---

# Example

Root Variable

```
variable "location" {}
```

terraform.tfvars

```
location = "Central India"
```

Module Call

```
module "resource_group" {

    location = var.location

}
```

Child Variable

```
variable "location" {}
```

Resource

```
resource "azurerm_resource_group" "rg" {

    location = var.location

}
```

Finally

Azure creates

```
Location = Central India
```

---

# What Happens if Child Variable Doesn't Exist?

Example

```
module "resource_group" {

    location = var.location

}
```

But Child Module has

```
(No variable "location")
```

Terraform Error

```
Unsupported argument

An argument named "location"
is not expected here.
```

Because the child module never declared that input.

---

# What Happens if Root Variable Doesn't Exist?

Suppose

```
module "resource_group" {

    location = var.location

}
```

But Root Module has

```
(No variable "location")
```

Terraform Error

```
Reference to undeclared input variable

location
```

Because Root Module doesn't know where the value comes from.

---

# Why Can't Child Module Read terraform.tfvars?

Because

```
terraform.tfvars
```

belongs only to the Root Module.

Child Modules never read

```
terraform.tfvars
```

They only receive values from the Root Module.

---

# Variable Journey

```
terraform.tfvars

↓

Root Variable

↓

module block

↓

Child Variable

↓

Resource

↓

Azure
```

This is the complete lifecycle of a variable.

---

# Think Like a Function

Terraform Module is similar to a programming function.

Function

```
add(10,20)
```

10 and 20 are inputs.

Terraform

```
module "resource_group" {

    rg_name = var.rg_name

}
```

Same concept.

The module accepts inputs.

---

# Rule to Remember

✅ Root Module receives values.

✅ Child Module receives values from Root Module.

✅ Child Module never reads terraform.tfvars.

✅ Modules cannot directly access each other's variables.

✅ Every module has its own variables.tf.

---

# Quick Interview Answer

**Q. Why do we define the same variable in both the Root Module and the Child Module?**

**Answer:**

The Root Module declares variables to accept values from `terraform.tfvars`, environment variables, or the CLI. It then passes those values to the Child Module using the `module` block. The Child Module declares its own variables because modules are isolated and can only access values explicitly passed to them. This design makes modules reusable, independent, and easy to use across different environments like Dev, Test, and Production.

---

# Golden Rule

```
terraform.tfvars

        ↓

Root Variables

        ↓

Module Block

        ↓

Child Variables

        ↓

Azure Resource
```

If you remember this diagram, you'll understand Terraform variable flow forever.