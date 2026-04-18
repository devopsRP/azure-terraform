# Terraform Dependency (Implicit & Explicit) with Azure Example ☁️

This document explains how **Terraform handles dependencies** between resources using both **implicit** and **explicit** methods.

---

## 📌 What is Dependency in Terraform?

In Terraform, a dependency means:

> One resource must be created before another.

Terraform automatically builds a dependency graph (DAG) to determine the correct order of resource creation.

---

## 🔗 1. Implicit Dependency (Automatic)

Terraform automatically understands dependencies when one resource references another.

### ✅ Example: Resource Group → Storage Account

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "example-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "examplestorage123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### 🔍 Explanation

* Storage Account uses:

  * `azurerm_resource_group.rg.name`
  * `azurerm_resource_group.rg.location`
* Terraform automatically understands:

  👉 First create Resource Group
  👉 Then create Storage Account

No manual dependency required ✅

---

## ⚙️ 2. Explicit Dependency (`depends_on`)

Sometimes Terraform cannot detect dependencies automatically.
In such cases, we use **`depends_on`** to define it manually.

### ✅ Example with Explicit Dependency

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "example-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "examplestorage123"
  resource_group_name      = "example-rg"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [
    azurerm_resource_group.rg
  ]
}
```

### 🔍 Explanation

* No direct reference used
* Terraform cannot automatically detect dependency
* `depends_on` ensures:

  👉 Resource Group is created first
  👉 Storage Account is created after

---

## ⚡ Key Differences

| Feature         | Implicit Dependency | Explicit Dependency (`depends_on`) |
| --------------- | ------------------- | ---------------------------------- |
| Detection       | Automatic           | Manual                             |
| Based on        | Resource references | Developer instruction              |
| Recommended     | ✅ Yes               | ⚠️ Only when needed                |
| Code complexity | Simple              | Slightly more verbose              |

---

## 🧠 Best Practices

* Prefer **implicit dependency** whenever possible
* Use **explicit dependency only when required**
* Avoid unnecessary `depends_on` (it slows execution)
* Keep code clean and readable

---

## 📊 How Terraform Works Internally

Terraform creates a **dependency graph (DAG)**:

* Independent resources → created in parallel ⚡
* Dependent resources → created in sequence 🔗

---

## 🧾 Summary

* Terraform manages resource order automatically
* Use references → implicit dependency
* Use `depends_on` → explicit dependency
* Proper dependency ensures reliable infrastructure deployment

---


