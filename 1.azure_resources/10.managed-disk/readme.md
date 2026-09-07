# Azure Managed Disk — Complete Notes

## 1. What is Azure Managed Disk?

An **Azure Managed Disk** is a block-level storage volume managed by Microsoft Azure and designed to be used with Azure Virtual Machines.

In simple words:

> **Managed Disk is the virtual hard disk/storage attached to an Azure VM.**

It is similar to a physical hard disk in a traditional server, but Azure manages the underlying storage infrastructure for you.

---

# 2. One-Line Definition

> **Azure Managed Disk is a durable block storage service that provides virtual disks for Azure Virtual Machines.**

---

# 3. Why Do We Need Managed Disks?

Azure VMs need storage for:

* Operating systems
* Applications
* Databases
* Logs
* Configuration files
* Application data
* Temporary workloads

For example:

```text
Azure VM
   |
   +---- OS Disk
   |
   +---- Data Disk
   |
   +---- Data Disk
```

The OS disk contains the operating system, while additional managed disks can be used for application and data storage.

---

# 4. Simple Real-World Example

Suppose we create a Linux VM:

```text
        Azure VM
           |
     +-----+-----+
     |           |
     v           v
   OS Disk     Data Disk
     |           |
     v           v
  Ubuntu      Application
             Data / DB
```

The VM uses the OS disk to boot the operating system.

The data disk can store application data.

---

# 5. What Does "Managed" Mean?

Before Managed Disks, users had more responsibility for managing storage accounts used for VM disks.

With Managed Disks:

```text
User
 |
 | Creates Managed Disk
 v
Azure
 |
 +-- Storage infrastructure
 +-- Availability
 +-- Placement
 +-- Disk management
```

Azure manages much of the underlying storage infrastructure.

### Important

You still manage:

* Disk size
* Disk type/SKU
* Performance requirements
* Attachment to VMs
* Partitioning
* Formatting
* File system
* Application-level data

Azure manages the underlying physical storage infrastructure.

---

# 6. Architecture

A basic architecture looks like:

```text
                    Azure
                      |
              +-------+-------+
              |               |
              v               v
          Virtual Machine   Managed Disk
              |               |
              |               |
              +-------+-------+
                      |
                    Attach
                      |
                      v
                    VM
```

More practically:

```text
                    Resource Group
                          |
             +------------+------------+
             |                         |
             v                         v
        Virtual Machine          Managed Disk
             |                         |
             |                         |
             +-----------+-------------+
                         |
                       Attach
                         |
                         v
                    Data Storage
```

---

# 7. Your Terraform Code

Your configuration creates:

```text
Resource Group
      |
      v
Managed Disk
```

Your main resources are:

```hcl
azurerm_resource_group
azurerm_managed_disk
```

The Managed Disk is created independently.

It is **not automatically attached to a VM** by the code you provided.

---

# 8. Your Resource Group

Your code contains:

```hcl
resource "azurerm_resource_group" "rg-block" {

  name     = "managed-disk-rg"

  location = "centralindia"

}
```

### Definition

> A Resource Group is a logical container used to organize and manage Azure resources.

Architecture:

```text
managed-disk-rg
      |
      v
Managed Disk
```

---

# 9. Your Managed Disk Resource

Your Terraform code contains:

```hcl
resource "azurerm_managed_disk" "source" {

  name                 = "acctestmd1"

  location             = azurerm_resource_group.rg-block.location

  resource_group_name  = azurerm_resource_group.rg-block.name

  storage_account_type = "Standard_LRS"

  create_option        = "Empty"

  disk_size_gb         = "1"

}
```

This creates an empty Azure Managed Disk.

---

# 10. `name`

```hcl
name = "acctestmd1"
```

This specifies the name of the Managed Disk.

### Definition

> Defines the name used to identify the Managed Disk in Azure.

---

# 11. `location`

```hcl
location = azurerm_resource_group.rg-block.location
```

The disk uses the same location as the Resource Group.

In your configuration:

```text
Resource Group
     |
     +-- Location: Central India
     |
     +-- Managed Disk
           |
           +-- Location: Central India
```

### Important

A Managed Disk is a regional resource.

When attaching it to a VM, the disk and VM generally need to be in compatible locations/regions.

---

# 12. `resource_group_name`

```hcl
resource_group_name = azurerm_resource_group.rg-block.name
```

This places the Managed Disk inside the specified Resource Group.

Terraform dependency:

```text
Resource Group
      |
      v
Managed Disk
```

Terraform understands this dependency because the disk references the Resource Group.

---

# 13. `storage_account_type`

Your configuration uses:

```hcl
storage_account_type = "Standard_LRS"
```

This defines the storage performance/redundancy option for the disk.

---

# 14. What is Standard_LRS?

`Standard_LRS` means:

**Standard Locally Redundant Storage**

It is a Standard HDD-based managed disk option.

In simple terms:

```text
Standard_LRS
     |
     +-- Standard performance
     |
     +-- Locally redundant storage
     |
     +-- Lower cost
```

It can be suitable for workloads that don't require high disk performance.

---

# 15. Common Managed Disk Types

Azure provides different managed disk options for different performance requirements.

Common categories include:

```text
Standard HDD
Standard SSD
Premium SSD
Premium SSD v2
Ultra Disk
```

The exact SKU names and availability can vary by Azure region and current Azure offerings.

---

# 16. Standard HDD

Standard HDD disks are generally intended for:

* Lower-cost storage
* Development/test environments
* Less performance-sensitive workloads
* Infrequently accessed workloads

Example:

```text
VM
 |
 +-- Standard HDD
```

### Advantage

Lower cost.

### Disadvantage

Lower performance compared with SSD-based options.

---

# 17. Standard SSD

Standard SSD provides better performance than Standard HDD.

Common use cases:

* Web servers
* Development environments
* General workloads
* Applications requiring moderate performance

Architecture:

```text
VM
 |
 +-- Standard SSD
```

---

# 18. Premium SSD

Premium SSD is designed for workloads that need higher performance and lower latency.

Common examples:

* Production applications
* Databases
* High-performance application servers
* I/O-intensive workloads

```text
Application
    |
    v
   VM
    |
    v
Premium SSD
```

---

# 19. Premium SSD v2

Premium SSD v2 provides more flexible performance characteristics for supported workloads.

It is designed for workloads requiring configurable performance and scalable storage characteristics.

Always check the current Azure documentation for regional and feature-specific requirements before selecting it.

---

# 20. Ultra Disk

Ultra Disk is designed for extremely demanding workloads.

Typical examples:

* High-performance databases
* Transaction-heavy workloads
* Very high IOPS requirements
* Very low latency requirements

Architecture:

```text
Database VM
     |
     v
Ultra Disk
```

---

# 21. Disk Type Comparison

| Disk Type      | Performance   | Cost     | Typical Use                     |
| -------------- | ------------- | -------- | ------------------------------- |
| Standard HDD   | Low           | Lower    | Dev/Test, low I/O               |
| Standard SSD   | Medium        | Moderate | General workloads               |
| Premium SSD    | High          | Higher   | Production workloads            |
| Premium SSD v2 | High/Flexible | Higher   | Performance-sensitive workloads |
| Ultra Disk     | Very High     | High     | Critical high-I/O workloads     |

Exact performance and pricing depend on disk size, SKU, region, and configuration.

---

# 22. `create_option`

Your code uses:

```hcl
create_option = "Empty"
```

### Definition

> `create_option` specifies how the Managed Disk should be created or sourced.

In your configuration:

```text
create_option = Empty
```

means:

> Create a new empty disk.

---

# 23. Empty Managed Disk

An empty Managed Disk contains no initial data.

```text
Managed Disk
     |
     v
   EMPTY
```

After attaching it to a VM, you can initialize and format it from inside the operating system.

Example Linux flow:

```text
Attach Disk
     |
     v
Detect Disk
     |
     v
Partition
     |
     v
Format
     |
     v
Mount
     |
     v
Store Data
```

---

# 24. `disk_size_gb`

Your configuration:

```hcl
disk_size_gb = "1"
```

defines the disk size.

### Definition

> `disk_size_gb` specifies the capacity of the Managed Disk in gigabytes.

Your disk:

```text
Size = 1 GB
```

---

# 25. Important: Disk Creation vs Disk Attachment

Creating a Managed Disk does **not automatically attach it to a VM**.

Your current architecture is:

```text
Resource Group
      |
      v
Managed Disk
```

To use it with a VM:

```text
Resource Group
      |
      +-- VM
      |
      +-- Managed Disk
              |
              v
           Attached
              |
              v
             VM
```

---

# 26. Attaching a Managed Disk

A Managed Disk can be attached to a VM through an appropriate VM disk attachment configuration.

Conceptually:

```text
VM
 |
 +---- OS Disk
 |
 +---- Data Disk
```

The data disk can then be initialized and mounted inside the operating system.

---

# 27. OS Disk vs Data Disk

There are two important disk concepts.

## OS Disk

Contains the operating system.

```text
VM
 |
 +-- OS Disk
       |
       +-- Windows
       OR
       +-- Linux
```

The VM boots from the OS disk.

---

## Data Disk

Used to store application/data files.

```text
VM
 |
 +-- OS Disk
 |
 +-- Data Disk
 |
 +-- Data Disk
```

Data disks are useful for:

* Database files
* Application files
* Logs
* Documents
* Backup data

---

# 28. Temporary Disk

Some Azure VM sizes also provide a temporary/local disk.

Important:

> Temporary disk storage is not intended for persistent data.

It can be used for:

* Temporary files
* Cache
* Page/swap files
* Scratch data

Do not use temporary disk storage as the only location for important persistent data.

---

# 29. Managed Disk Lifecycle

A simplified lifecycle is:

```text
Create
  |
  v
Managed Disk
  |
  v
Attach to VM
  |
  v
Initialize
  |
  v
Partition
  |
  v
Format
  |
  v
Mount
  |
  v
Use
  |
  v
Detach
  |
  v
Delete / Reuse
```

---

# 30. How Managed Disk Works

Suppose we create:

```text
Disk:
100 GB

Type:
Premium SSD
```

The architecture becomes:

```text
Application
    |
    v
Azure VM
    |
    v
Managed Disk
    |
    v
Azure Storage Infrastructure
```

The application sees the disk as block storage.

Azure manages the underlying storage infrastructure.

---

# 31. Managed Disk and VM Dependency

A typical dependency looks like:

```text
Resource Group
      |
      +----------------+
      |                |
      v                v
     VM          Managed Disk
      |                |
      +-------+--------+
              |
              v
           Attached
```

Terraform can manage these dependencies.

---

# 32. Managed Disk Snapshots

Azure supports snapshots for Managed Disks.

A snapshot is a point-in-time copy of disk data.

Conceptually:

```text
Managed Disk
     |
     v
 Snapshot
     |
     v
 Point-in-time copy
```

Snapshots can be useful for:

* Backup workflows
* Testing
* Creating new disks
* Disaster recovery processes
* Creating disk copies

---

# 33. Managed Disk Backup

Managed Disk snapshots are not the same thing as a complete backup strategy.

For production systems, consider appropriate Azure backup and disaster-recovery services according to the workload.

Important:

> A snapshot is a point-in-time disk copy, while a backup strategy may include retention, recovery management, policies, and application-consistent protection.

---

# 34. Disk Encryption

Azure Managed Disks support encryption capabilities.

Encryption helps protect data at rest.

Conceptually:

```text
Application
    |
    v
Managed Disk
    |
    v
Encrypted Storage
```

Azure supports multiple encryption approaches depending on the workload and requirements.

Examples include:

* Platform-managed encryption
* Customer-managed keys
* Encryption at host
* Server-side encryption

Always choose the encryption approach based on security and compliance requirements.

---

# 35. Advantages of Managed Disks

## 35.1 Easy Management

Azure manages much of the underlying storage infrastructure.

---

## 35.2 Scalability

Managed Disks are designed to support Azure VM workloads at scale.

---

## 35.3 High Availability

Azure provides storage redundancy options depending on the selected disk/storage configuration.

---

## 35.4 Security

Managed Disks support encryption and Azure security capabilities.

---

## 35.5 Snapshots

You can create point-in-time disk copies.

---

## 35.6 Easy Integration with VMs

Managed Disks are designed specifically for Azure VM storage.

---

## 35.7 Terraform Automation

Managed Disks can be created and managed using Infrastructure as Code.

Example:

```text
Terraform
    |
    v
Managed Disk
    |
    v
Azure
```

---

# 36. Disadvantages / Limitations

## 36.1 Cost

Higher-performance disk types cost more.

For example:

```text
Standard HDD
     <
Standard SSD
     <
Premium SSD
     <
Ultra Disk
```

Generally, higher performance means higher cost.

---

## 36.2 Regional Considerations

Disk and VM placement must be planned carefully.

---

## 36.3 Performance Depends on SKU

A workload requiring high IOPS should not automatically use a low-performance disk.

---

## 36.4 Storage Does Not Equal Backup

Creating a Managed Disk does not automatically mean you have a complete backup strategy.

---

## 36.5 Application-Level Configuration Still Required

After attaching a disk, the operating system may still require:

```text
Partition
Format
Mount
```

---

# 37. When Should We Use Managed Disks?

Use Managed Disks when you need:

* VM storage
* Persistent application storage
* Database storage
* Separate data volumes
* Scalable block storage
* Terraform-managed storage
* Snapshot capability
* Azure-integrated disk management

---

# 38. When Should We Not Use a Managed Disk?

A Managed Disk may not be the right service if your primary requirement is:

* Object storage
* Shared file storage
* Static website files
* Large-scale unstructured object data

For these requirements, consider services such as:

```text
Azure Blob Storage
Azure Files
```

depending on the use case.

---

# 39. Managed Disk vs Blob Storage

| Managed Disk      | Blob Storage                      |
| ----------------- | --------------------------------- |
| Block storage     | Object storage                    |
| Primarily for VMs | Object/data storage               |
| Acts like a disk  | Stores objects/files              |
| OS/Data disks     | Images, documents, backups, media |
| Attached to VM    | Accessed through storage APIs     |

---

# 40. Managed Disk vs Azure Files

| Managed Disk              | Azure Files                        |
| ------------------------- | ---------------------------------- |
| Block storage             | Managed file shares                |
| Primarily attached to VMs | Shared file access                 |
| VM disk                   | SMB/NFS-based file share scenarios |
| Individual disk semantics | Shared filesystem semantics        |

---

# 41. Managed Disk vs Temporary Disk

| Managed Disk                  | Temporary Disk                                      |
| ----------------------------- | --------------------------------------------------- |
| Persistent                    | Temporary                                           |
| Managed by Azure              | Local to VM host                                    |
| Used for important data       | Used for temporary data                             |
| Survives normal VM operations | Data can be lost during certain VM lifecycle events |
| Suitable for OS/Data          | Suitable for cache/scratch                          |

---

# 42. Performance Concepts

When selecting a disk, consider:

### IOPS

**Input/Output Operations Per Second**

Measures the number of I/O operations that can be handled per second.

---

### Throughput

Measures how much data can be transferred over time.

Usually represented in:

```text
MB/s
GB/s
```

---

### Latency

Measures how long an I/O operation takes.

Lower latency generally means faster response for I/O operations.

---

# 43. Example Performance Thinking

Suppose:

```text
Application A
```

requires only moderate storage performance.

A Standard disk may be sufficient.

But:

```text
High-performance Database
```

may require:

```text
Premium SSD
```

or another high-performance disk option.

Therefore:

> **Choose the disk based on workload requirements, not simply the largest or fastest disk.**

---

# 44. Disk Sizing

When choosing disk size, consider:

```text
Current Data
+
Expected Growth
+
Performance Requirements
+
Backup Requirements
```

Example:

```text
Current Data = 100 GB
Expected Growth = 50 GB
Buffer = 50 GB

Required Capacity ≈ 200 GB
```

The exact sizing strategy depends on the workload.

---

# 45. Terraform Dependency in Your Code

Your Managed Disk contains:

```hcl
location = azurerm_resource_group.rg-block.location
```

and:

```hcl
resource_group_name = azurerm_resource_group.rg-block.name
```

Therefore Terraform understands:

```text
azurerm_resource_group
          |
          v
azurerm_managed_disk
```

The Resource Group must exist before the Managed Disk can be created.

---

# 46. Terraform Workflow

The standard Terraform workflow is:

```text
Write Code
    |
    v
terraform fmt
    |
    v
terraform init
    |
    v
terraform validate
    |
    v
terraform plan
    |
    v
terraform apply
```

---

# 47. Terraform Commands

### Initialize

```powershell
terraform init
```

Initializes Terraform and downloads required providers.

---

### Format

```powershell
terraform fmt
```

Formats Terraform configuration files.

---

### Validate

```powershell
terraform validate
```

Checks the Terraform configuration for syntax and configuration errors.

---

### Plan

```powershell
terraform plan
```

Shows the changes Terraform plans to make.

---

### Apply

```powershell
terraform apply
```

Creates or updates the Azure resources.

---

### Destroy

```powershell
terraform destroy
```

Deletes resources managed by Terraform.

---

# 48. Your Current Terraform Architecture

Your code creates:

```text
                    Terraform
                       |
                       v
                Resource Group
               managed-disk-rg
                       |
                       v
                 Managed Disk
                   acctestmd1
                       |
                       +-- 1 GB
                       |
                       +-- Standard_LRS
                       |
                       +-- Empty
```

The disk is currently standalone.

There is no VM attachment in the code provided.

---

# 49. Complete VM + Managed Disk Architecture

A more complete architecture would look like:

```text
                    Resource Group
                          |
             +------------+------------+
             |                         |
             v                         v
       Virtual Machine          Managed Disk
             |                         |
             |                         |
             +-----------+-------------+
                         |
                         v
                      Attached
                         |
                         v
                   Data Storage
```

---

# 50. Linux Managed Disk Workflow

After attaching a new empty disk to a Linux VM, the general process is:

```text
1. Attach disk
       |
       v
2. Detect disk
       |
       v
3. Create partition
       |
       v
4. Create filesystem
       |
       v
5. Create mount point
       |
       v
6. Mount disk
       |
       v
7. Configure persistent mount if required
```

Example conceptual commands:

```bash
lsblk
```

Check available disks.

Then, depending on the chosen filesystem and partitioning approach:

```bash
sudo fdisk
```

Create a partition.

Format the partition, for example:

```bash
sudo mkfs.ext4 /dev/sdc1
```

Create a mount point:

```bash
sudo mkdir /data
```

Mount:

```bash
sudo mount /dev/sdc1 /data
```

> Device names can differ between VMs and configurations, so verify the actual disk device before running disk commands.

---

# 51. Windows Managed Disk Workflow

For Windows:

```text
Attach Disk
     |
     v
Disk Management
     |
     v
Initialize Disk
     |
     v
Create Volume
     |
     v
Format
     |
     v
Assign Drive Letter
     |
     v
Use Disk
```

Example:

```text
C: = OS Disk

D: = Data Disk
```

---

# 52. Common Troubleshooting

## Problem 1: Disk Cannot Be Attached

Check:

* VM region
* Disk compatibility
* VM size limitations
* Disk state
* Attachment configuration

---

## Problem 2: Disk Is Attached But Not Visible in Linux

Check:

```bash
lsblk
```

and:

```bash
sudo fdisk -l
```

The disk may need to be partitioned and formatted.

---

## Problem 3: Disk Is Visible But Cannot Store Files

The disk may not have a filesystem or mount point.

General flow:

```text
Disk
 |
 v
Partition
 |
 v
Filesystem
 |
 v
Mount
```

---

## Problem 4: Performance Is Low

Check:

* Disk SKU
* Disk size
* IOPS requirements
* Throughput requirements
* VM size limits
* Application I/O pattern

---

# 53. Important Best Practices

### 1. Choose the Correct Disk Type

Do not use Premium or Ultra disks when Standard storage is sufficient.

---

### 2. Separate OS and Application Data

A common architecture is:

```text
VM
 |
 +-- OS Disk
 |
 +-- Data Disk
```

This provides better organization and can simplify data management.

---

### 3. Plan Capacity

Consider:

```text
Current Size
+
Growth
+
Operational Requirements
```

---

### 4. Plan Backup

Do not assume that having a Managed Disk means the data is automatically backed up according to your recovery requirements.

---

### 5. Use Encryption

Choose an encryption approach appropriate for your security requirements.

---

### 6. Use Terraform

Manage infrastructure consistently using Infrastructure as Code.

---

# 54. Important Interview Questions

## Q1. What is Azure Managed Disk?

> Azure Managed Disk is a block-level storage service designed for Azure VMs and provides persistent storage for OS and application data.

---

## Q2. Why do we use Managed Disks?

> We use Managed Disks to provide persistent and scalable storage for Azure Virtual Machines.

---

## Q3. What does "managed" mean?

> Azure manages the underlying storage infrastructure, while the user manages disk configuration, performance, attachment, and data usage.

---

## Q4. Is Managed Disk automatically attached to a VM?

> No. Creating a Managed Disk does not automatically attach it to a VM.

---

## Q5. What is Standard_LRS?

> Standard_LRS is a Standard HDD-based managed disk/storage option using locally redundant storage.

---

## Q6. What is `create_option = "Empty"`?

> It tells Terraform to create a new empty Managed Disk without initial disk contents.

---

## Q7. What is `disk_size_gb`?

> It specifies the capacity of the Managed Disk in gigabytes.

---

## Q8. What is the difference between OS Disk and Data Disk?

> OS Disk contains the operating system, while Data Disks are generally used for application and user data.

---

## Q9. What is a snapshot?

> A snapshot is a point-in-time copy of a Managed Disk.

---

## Q10. What is IOPS?

> IOPS means Input/Output Operations Per Second and measures how many I/O operations a storage system can perform per second.

---

## Q11. What is throughput?

> Throughput measures the amount of data that can be transferred over a period of time.

---

## Q12. What is latency?

> Latency is the time taken to complete an I/O operation.

---

## Q13. Managed Disk vs Blob Storage?

> Managed Disk provides block storage primarily for VMs, while Blob Storage provides object storage for files and unstructured data.

---

## Q14. Managed Disk vs Azure Files?

> Managed Disk provides block storage, while Azure Files provides managed shared file storage.

---

## Q15. Can we create a Managed Disk without a VM?

> Yes. A Managed Disk can exist independently and can be attached to a VM later.

---

# 55. Easy Memory Trick

Remember:

```text
MANAGED DISK = VM STORAGE
```

And remember the basic concepts:

```text
TYPE
  |
  v
Performance

SIZE
  |
  v
Capacity

ATTACH
  |
  v
VM Usage

SNAPSHOT
  |
  v
Point-in-time Copy

ENCRYPTION
  |
  v
Data Protection
```

---

# 56. Final Summary

Azure Managed Disk is persistent block storage for Azure Virtual Machines.

The basic architecture is:

```text
                         Azure
                           |
                    Resource Group
                           |
              +------------+------------+
              |                         |
              v                         v
       Virtual Machine            Managed Disk
              |                         |
              |                         |
              +-----------+-------------+
                          |
                        Attach
                          |
                          v
                    Persistent Data
```

Your Terraform code creates:

```text
Resource Group
      |
      v
Managed Disk
      |
      +-- Name: acctestmd1
      |
      +-- Type: Standard_LRS
      |
      +-- Creation: Empty
      |
      +-- Size: 1 GB
      |
      +-- Location: Central India
```

### Most Important Points

1. **Managed Disk = Azure VM block storage**
2. **OS Disk = Operating System**
3. **Data Disk = Application/Data storage**
4. **Managed does not mean automatically attached**
5. **`Standard_LRS` = Standard HDD-based option with locally redundant storage**
6. **`Empty` = Create a new empty disk**
7. **`disk_size_gb` = Disk capacity**
8. **Snapshot = Point-in-time disk copy**
9. **IOPS = Number of I/O operations per second**
10. **Throughput = Amount of data transferred**
11. **Latency = Time taken for an I/O operation**
12. **Choose disk type based on workload**
13. **Managed Disk is different from Blob Storage and Azure Files**
14. **Creating a disk does not automatically create a backup strategy**
15. **Terraform can automate Managed Disk creation and management**

---

# 57. One-Line Interview Answer

> **Azure Managed Disk is a persistent, block-level storage service for Azure VMs that provides scalable and durable storage without requiring users to manage the underlying storage infrastructure.**
