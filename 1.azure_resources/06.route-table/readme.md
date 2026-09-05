# Azure Route Table – Notes

## 1. What is a Route Table?

An **Azure Route Table** is a collection of custom routes that controls how network traffic is directed between subnets, virtual networks, virtual appliances, and other network destinations in Azure.

In simple words:

> **A Route Table tells Azure where network traffic should go.**

Azure automatically creates some routes for network communication. When we need to control or customize the traffic path, we can create a **User Defined Route (UDR)** using an Azure Route Table.

---

# 2. Why Do We Need a Route Table?

Route tables are used when the default Azure routing behavior is not sufficient for our network design.

Common reasons:

* To control network traffic flow
* To send traffic through a firewall
* To send traffic through a Network Virtual Appliance (NVA)
* To force internet traffic through a security appliance
* To control communication between network segments
* To implement centralized network security
* To create custom routing between networks
* To inspect traffic before it reaches another network
* To control traffic between Azure and on-premises networks

### Simple Example

Suppose we have:

```text
VM
 |
Subnet
 |
Route Table
 |
Virtual Firewall
 |
Internet
```

Instead of allowing the VM to communicate directly with the Internet, we can configure the route table to send traffic to a firewall first.

---

# 3. How Does an Azure Route Table Work?

The basic flow is:

```text
Source
  |
  v
Subnet
  |
  v
Route Table
  |
  v
Route
  |
  v
Next Hop
  |
  v
Destination
```

A route normally contains:

```text
Destination Network
        +
Next Hop
```

For example:

```text
Destination: 10.100.0.0/14
Next Hop: Virtual Appliance
Next Hop IP: 10.10.1.1
```

This means:

> If traffic is going to `10.100.0.0/14`, send it to the virtual appliance at `10.10.1.1`.

---

# 4. Main Components

## 4.1 Route Table

The Route Table is the main Azure networking resource that contains custom routes.

Example:

```hcl
resource "azurerm_route_table" "route-table-block" {
  name                = "routetable"
  location            = azurerm_resource_group.RG-block.location
  resource_group_name = azurerm_resource_group.RG-block.name
}
```

### Definition

> A Route Table is a collection of custom network routes used to control traffic forwarding.

---

# 5. Route

A route defines where traffic destined for a particular network should be sent.

Example:

```hcl
route {
  name                   = "route1"
  address_prefix         = "10.100.0.0/14"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.10.1.1"
}
```

### Definition

> A route defines a destination network and the next hop that should receive traffic for that network.

---

# 6. Address Prefix

`address_prefix` defines the destination network.

Example:

```hcl
address_prefix = "10.100.0.0/14"
```

It means traffic going to:

```text
10.100.0.0/14
```

will follow this route.

### Definition

> Address Prefix specifies the destination IP network to which the route applies.

---

# 7. Next Hop

The **Next Hop** is the destination where Azure sends the traffic after matching a route.

Example:

```hcl
next_hop_type = "VirtualAppliance"
```

The virtual appliance IP is:

```hcl
next_hop_in_ip_address = "10.10.1.1"
```

### Definition

> Next Hop specifies the type of destination or device to which Azure forwards matching traffic.

---

# 8. Common Next Hop Types

Azure supports different next-hop types.

| Next Hop Type      | Meaning                                     |
| ------------------ | ------------------------------------------- |
| `VirtualNetwork`   | Route traffic inside the virtual network    |
| `Internet`         | Send traffic to the Internet                |
| `VirtualAppliance` | Send traffic to a network virtual appliance |
| `None`             | Drop the traffic                            |
| `VnetLocal`        | Traffic stays within the VNet               |

> The exact available values can depend on the Azure resource/provider version being used.

---

# 9. What is a Virtual Appliance?

A **Virtual Appliance** is a virtual machine or network appliance that performs network functions.

Examples:

* Firewall
* IDS/IPS
* Network inspection appliance
* Router
* Proxy
* Security appliance

Example:

```text
VM
 |
 v
Route Table
 |
 v
10.10.1.1
 |
 v
Firewall / NVA
 |
 v
Internet
```

The route table forces traffic through the appliance.

---

# 10. Route Table Association

Creating a route table alone does not make it control traffic for a subnet.

The route table must be **associated with a subnet**.

Conceptually:

```text
Route Table
     |
     |
     v
  Subnet
     |
     v
   VMs
```

Example Terraform:

```hcl
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.example.id
  route_table_id = azurerm_route_table.route-table-block.id
}
```

### Definition

> Route Table Association connects a route table to a subnet so that the subnet can use its custom routes.

---

# 11. Important Point

A Route Table is generally associated with a **subnet**, not directly with an individual VM.

For example:

```text
VNet
 |
 +-- Subnet-1
 |     |
 |     +-- VM-1
 |     +-- VM-2
 |
 +-- Subnet-2
       |
       +-- VM-3
```

If a route table is associated with `Subnet-1`:

```text
Route Table
     |
     v
Subnet-1
  /   \
VM-1  VM-2
```

The custom routes apply to resources using that subnet.

---

# 12. Default Routes vs User Defined Routes

Azure has system/default routes that provide basic connectivity.

Example:

```text
VNet
 |
 +-- Subnet
       |
       +-- VM
```

Azure automatically knows how to route traffic within the VNet.

But sometimes we need custom routing.

That's where:

```text
User Defined Route (UDR)
```

is used.

---

# 13. What is UDR?

UDR stands for:

**User Defined Route**

A UDR is a custom route created by the Azure user to control traffic routing.

Example:

```text
10.100.0.0/14
        |
        v
Virtual Appliance
        |
        v
10.10.1.1
```

In Terraform:

```hcl
route {
  name                   = "route1"
  address_prefix         = "10.100.0.0/14"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.10.1.1"
}
```

---

# 14. Route Selection

When multiple routes are available, Azure uses routing rules to determine which route should be selected.

One important principle is:

> **The most specific route generally wins.**

For example:

```text
Route 1:
10.0.0.0/8

Route 2:
10.10.0.0/16
```

For traffic destined to:

```text
10.10.1.10
```

the `/16` route is more specific than `/8`, so the more specific route can be selected.

This is known as **Longest Prefix Match**.

---

# 15. Route Table Example

Suppose we have:

```text
Application VM
     |
     v
Application Subnet
     |
     v
Route Table
     |
     v
Firewall
10.10.1.1
```

Route:

```text
Destination: 0.0.0.0/0
Next Hop: Virtual Appliance
Next Hop IP: 10.10.1.1
```

This means:

```text
All destinations
     |
     v
0.0.0.0/0
     |
     v
Firewall
10.10.1.1
```

The firewall can then inspect and control the traffic.

---

# 16. What is 0.0.0.0/0?

```text
0.0.0.0/0
```

represents the default route.

In simple terms:

> It matches traffic for destinations that do not have a more specific route.

Example:

```text
0.0.0.0/0
     |
     v
Virtual Appliance
```

This can be used to force outbound traffic through a firewall/NVA.

---

# 17. Advantages of Route Tables

## 17.1 Traffic Control

Route tables provide control over how traffic moves through the Azure network.

---

## 17.2 Security

Traffic can be forced through:

* Firewall
* IDS/IPS
* NVA
* Security appliance

This allows traffic inspection and security enforcement.

---

## 17.3 Centralized Network Architecture

Route tables can help implement centralized network security.

Example:

```text
Spoke VNet
    |
    v
Hub VNet
    |
    v
Azure Firewall
    |
    v
Internet
```

This is common in **Hub-and-Spoke** network architectures.

---

## 17.4 Custom Routing

Azure default routes may not satisfy every architecture.

UDRs allow custom traffic paths.

---

## 17.5 Network Segmentation

Different subnets can use different routing configurations.

Example:

```text
Web Subnet
    |
    +--> Route Table 1

App Subnet
    |
    +--> Route Table 2

Database Subnet
    |
    +--> Route Table 3
```

---

## 17.6 Traffic Inspection

Traffic can be redirected through a security appliance.

```text
VM
 |
 v
UDR
 |
 v
Firewall
 |
 v
Destination
```

---

# 18. Disadvantages / Limitations

Route tables are powerful, but incorrect configuration can cause problems.

### 1. Routing Complexity

Large environments can become difficult to manage.

### 2. Incorrect Routes

A wrong route can cause:

* Connection failure
* Asymmetric routing
* Unexpected traffic paths
* Application connectivity problems

### 3. Troubleshooting

Routing problems can sometimes be difficult to identify.

### 4. Dependency on Network Appliances

If traffic is forced through an appliance, that appliance becomes an important dependency.

### 5. Maintenance

Large numbers of custom routes require proper documentation and management.

---

# 19. Route Table vs NSG

A Route Table and NSG perform different jobs.

| Feature                | Route Table     | NSG               |
| ---------------------- | --------------- | ----------------- |
| Main purpose           | Traffic routing | Traffic filtering |
| Controls path          | Yes             | No                |
| Allows/denies traffic  | Not primarily   | Yes               |
| Custom routes          | Yes             | No                |
| Firewall replacement   | No              | No                |
| Associated with subnet | Yes             | Yes               |
| Can associate with NIC | No              | Yes               |

### Easy Interview Answer

> **Route Table decides where traffic should go, while NSG decides whether traffic is allowed or denied.**

---

# 20. Route Table vs Azure Firewall

| Route Table                                  | Azure Firewall                 |
| -------------------------------------------- | ------------------------------ |
| Controls routing                             | Provides network security      |
| Determines next hop                          | Inspects and filters traffic   |
| Lightweight routing component                | Managed security service       |
| Can send traffic to firewall                 | Can receive traffic from UDR   |
| Does not provide full firewall functionality | Provides firewall capabilities |

They are often used together.

```text
VM
 |
 v
Route Table
 |
 v
Azure Firewall
 |
 v
Internet
```

---

# 21. Terraform Example

A basic Azure Route Table can be created using:

```hcl
resource "azurerm_route_table" "route-table-block" {

  name                = "routetable"

  location            = azurerm_resource_group.RG-block.location

  resource_group_name = azurerm_resource_group.RG-block.name

  route {

    name                   = "route1"

    address_prefix         = "10.100.0.0/14"

    next_hop_type          = "VirtualAppliance"

    next_hop_in_ip_address = "10.10.1.1"

  }

}
```

This creates:

```text
Route Table
     |
     v
Destination: 10.100.0.0/14
     |
     v
Virtual Appliance
     |
     v
10.10.1.1
```

---

# 22. Real-World Use Case

Imagine a company has:

```text
                Internet
                   |
                   v
             Azure Firewall
                   |
          +--------+--------+
          |                 |
          v                 v
      Web VNet          App VNet
          |                 |
          v                 v
       Web VM            App VM
```

The company wants all application traffic to pass through the firewall.

A route table can contain:

```text
Destination:
0.0.0.0/0

Next Hop:
Virtual Appliance

Next Hop IP:
Firewall Private IP
```

Flow:

```text
Application VM
      |
      v
Route Table
      |
      v
Azure Firewall
      |
      v
Internet
```

This provides centralized control over network traffic.

---

# 23. Route Table Workflow

The general implementation process is:

```text
1. Create Resource Group
          |
          v
2. Create VNet
          |
          v
3. Create Subnet
          |
          v
4. Create Route Table
          |
          v
5. Create Custom Route
          |
          v
6. Specify Destination
          |
          v
7. Specify Next Hop
          |
          v
8. Associate Route Table with Subnet
          |
          v
9. Test Traffic
```

---

# 24. Important Terraform Resources

Common Terraform resources related to Azure routing include:

```text
azurerm_resource_group
azurerm_virtual_network
azurerm_subnet
azurerm_route_table
azurerm_route
azurerm_subnet_route_table_association
```

Their basic purpose:

| Resource                                 | Purpose                            |
| ---------------------------------------- | ---------------------------------- |
| `azurerm_resource_group`                 | Creates resource group             |
| `azurerm_virtual_network`                | Creates VNet                       |
| `azurerm_subnet`                         | Creates subnet                     |
| `azurerm_route_table`                    | Creates route table                |
| `azurerm_route`                          | Creates custom route               |
| `azurerm_subnet_route_table_association` | Associates route table with subnet |

---

# 25. Key Terms

### Route Table

Collection of routes used to control network traffic.

### Route

Defines destination and next hop.

### UDR

User Defined Route created by the user.

### Address Prefix

Destination network.

### Next Hop

Where matching traffic should be sent.

### Virtual Appliance

Network appliance used to process or route traffic.

### Subnet Association

Connects a route table to a subnet.

### Longest Prefix Match

More specific route takes precedence over a less specific route.

### Default Route

```text
0.0.0.0/0
```

Matches general IPv4 traffic when no more specific route is selected.

---

# 26. Interview Questions and Answers

## Q1. What is an Azure Route Table?

**Answer:**

An Azure Route Table is a collection of custom routes used to control how network traffic is routed between Azure networks and other destinations.

---

## Q2. Why do we use a Route Table?

**Answer:**

We use route tables when we need custom routing, such as sending traffic through a firewall, NVA, or other virtual appliance.

---

## Q3. What is UDR?

**Answer:**

UDR stands for User Defined Route. It is a custom route created by the user to control network traffic.

---

## Q4. Where is a Route Table associated?

**Answer:**

A route table is associated with a subnet.

---

## Q5. Can we associate a Route Table directly with a VM?

**Answer:**

No. Route tables are associated with subnets. VMs inside the subnet can then use the subnet's effective routes.

---

## Q6. What is the purpose of `address_prefix`?

**Answer:**

It specifies the destination IP address range for the route.

---

## Q7. What is `next_hop_type`?

**Answer:**

It specifies where Azure should send traffic after matching the route.

---

## Q8. What is `VirtualAppliance`?

**Answer:**

It indicates that traffic should be forwarded to a virtual network appliance, such as a firewall or NVA.

---

## Q9. What is `next_hop_in_ip_address`?

**Answer:**

It specifies the private IP address of the virtual appliance that should receive the traffic.

---

## Q10. What is 0.0.0.0/0?

**Answer:**

It is the default IPv4 route and represents all IPv4 destinations.

---

## Q11. What is the difference between Route Table and NSG?

**Answer:**

A Route Table controls **where traffic goes**, while an NSG controls **whether traffic is allowed or denied**.

---

## Q12. What happens if we create a Route Table but don't associate it with a subnet?

**Answer:**

The custom routes in that route table will not affect traffic from the subnet because the route table has not been applied to the subnet.

---

# 27. Easy Way to Remember

Remember:

```text
ROUTE TABLE = WHERE?

NSG = ALLOW / DENY?

FIREWALL = INSPECT / FILTER?

SUBNET = WHERE RESOURCES LIVE?
```

Or:

```text
Route Table
     |
     +--> Where should traffic go?

NSG
     |
     +--> Is traffic allowed?

Firewall
     |
     +--> Can traffic be inspected/filtered?
```

---

# 28. One-Line Definition

> **Azure Route Table is a networking resource that contains custom routes to control where traffic from a subnet should be forwarded.**

---

# 29. One-Line Interview Answer

> **We use Azure Route Tables/UDRs to customize network traffic paths, commonly to force traffic through a firewall, NVA, or other network appliance.**

---

# 30. Final Summary

```text
                    Azure Route Table
                           |
                           v
                    Contains Routes
                           |
                           v
                   Destination Prefix
                           |
                           v
                       Next Hop
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
        VirtualNetwork  Internet   VirtualAppliance
                                       |
                                       v
                                  Firewall / NVA
```

The most important concepts to remember are:

1. **Route Table = traffic routing**
2. **UDR = custom route**
3. **Route Table is associated with a subnet**
4. **Address Prefix = destination network**
5. **Next Hop = where traffic goes**
6. **Virtual Appliance = firewall/NVA/etc.**
7. **0.0.0.0/0 = default IPv4 route**
8. **More specific routes generally take precedence**
9. **Route Table controls traffic path**
10. **NSG controls traffic allow/deny**
11. **Route Tables are commonly used with Azure Firewall**
12. **Always test and verify effective routes when troubleshooting**

---

## Quick Memory Trick

```text
                    ROUTE TABLE
                         |
                         v
                   "WHERE TO GO?"
                         |
              +----------+----------+
              |          |          |
              v          v          v
          Network    Internet    Appliance
```

> **Route Table tells the traffic WHERE to go.**
