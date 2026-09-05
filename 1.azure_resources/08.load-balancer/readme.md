# Azure Load Balancer

## 1. Definition

**Azure Load Balancer** is a Layer 4 (TCP/UDP) load-balancing service in Microsoft Azure that distributes incoming network traffic across multiple backend resources.

### One-Line Definition

> **Azure Load Balancer distributes network traffic across multiple backend resources to improve availability, scalability, and reliability.**

---

# 2. What is a Load Balancer?

Suppose we have only one server:

```text
              Client
                 |
                 v
              Server
```

If the server goes down:

```text
              Client
                 |
                 X
              Server
             DOWN
```

The application becomes unavailable.

Now suppose we have multiple servers:

```text
                 Client
                    |
                    v
              Load Balancer
               /    |    \
              /     |     \
             v      v      v
          VM-1    VM-2    VM-3
```

The Load Balancer distributes incoming traffic between the backend servers.

If one VM becomes unavailable:

```text
                 Client
                    |
                    v
              Load Balancer
               /         \
              v           v
           VM-1          VM-3
          DOWN           UP
```

The Load Balancer can stop sending traffic to the unhealthy backend.

---

# 3. Why Do We Need a Load Balancer?

A Load Balancer is used for:

* High availability
* Traffic distribution
* Application scalability
* Fault tolerance
* Removing unhealthy backend servers from traffic
* Supporting multiple backend VMs
* Handling increased traffic
* Providing a single frontend IP for clients

---

# 4. Real-World Example

Imagine an application has three web servers:

```text
             Internet Users
                   |
                   v
            Public IP Address
                   |
                   v
            Azure Load Balancer
             /       |       \
            /        |        \
           v         v         v
        Web-VM1   Web-VM2   Web-VM3
```

Users do not need to know the individual VM IP addresses.

They connect to the Load Balancer's frontend IP.

The Load Balancer distributes the traffic to the backend VMs.

---

# 5. Basic Architecture

```text
                         Internet
                            |
                            v
                     Public IP Address
                            |
                            v
                  +--------------------+
                  |  Azure Load        |
                  |  Balancer          |
                  +--------------------+
                            |
                 +----------+----------+
                 |          |          |
                 v          v          v
              VM-1        VM-2       VM-3
                 |          |          |
                 +----------+----------+
                            |
                            v
                       Application
```

---

# 6. Main Components

Azure Load Balancer contains several important components.

```text
Load Balancer
     |
     +-- Frontend IP
     |
     +-- Backend Pool
     |
     +-- Health Probe
     |
     +-- Load Balancing Rule
     |
     +-- Inbound NAT Rule
     |
     +-- Outbound Rule
```

The most important components are:

1. Frontend IP Configuration
2. Backend Pool
3. Health Probe
4. Load Balancing Rule

---

# 7. Frontend IP Configuration

The **Frontend IP** is the IP address through which clients access the Load Balancer.

Example:

```text
Client
  |
  v
Public IP
  |
  v
Load Balancer
```

In your Terraform code:

```hcl
frontend_ip_configuration {

  name                 = "PublicIPAddress"

  public_ip_address_id = azurerm_public_ip.pip-block.id

}
```

### Definition

> Frontend IP is the IP address exposed by the Load Balancer for receiving network traffic.

---

# 8. Public IP

A Public IP is required when the Load Balancer needs to receive traffic from the Internet.

Your Terraform code creates:

```hcl
resource "azurerm_public_ip" "pip-block" {

  name                = "PublicIPForLB"

  location            = azurerm_resource_group.rg-block.location

  resource_group_name = azurerm_resource_group.rg-block.name

  allocation_method   = "Static"

}
```

Architecture:

```text
Internet
   |
   v
Public IP
   |
   v
Load Balancer
```

### Definition

> A Public IP provides an Internet-reachable IP address for the Load Balancer frontend.

---

# 9. Backend Pool

The **Backend Pool** contains the backend resources that receive traffic from the Load Balancer.

Example:

```text
Load Balancer
      |
      v
Backend Pool
  /    |    \
 VM1  VM2   VM3
```

### Definition

> Backend Pool is a collection of backend resources that receive traffic from the Load Balancer.

Backend resources can include supported Azure resources such as:

* Virtual Machines
* Virtual Machine Scale Sets
* Network interfaces

---

# 10. Health Probe

A **Health Probe** checks whether backend resources are healthy and available to receive traffic.

Example:

```text
Load Balancer
      |
      |---- Health Probe ---> VM1
      |
      |---- Health Probe ---> VM2
      |
      |---- Health Probe ---> VM3
```

If VM2 fails the health check:

```text
VM1 = Healthy
VM2 = Unhealthy
VM3 = Healthy
```

Traffic can be distributed to:

```text
VM1
VM3
```

instead of:

```text
VM2
```

### Definition

> A Health Probe checks the health and availability of backend resources before sending traffic to them.

---

# 11. How Health Probe Works

Suppose we configure:

```text
Protocol: TCP
Port: 80
```

The Load Balancer checks whether the backend can respond on port 80.

Conceptually:

```text
Load Balancer
      |
      | TCP 80
      v
    VM-1
      |
      v
   Healthy
```

If the service is not available:

```text
Load Balancer
      |
      | TCP 80
      v
    VM-1
      |
      X
   Unhealthy
```

The Load Balancer can stop sending new traffic to that backend.

---

# 12. Load Balancing Rule

A **Load Balancing Rule** defines how traffic received on the frontend should be distributed to the backend pool.

Example:

```text
Frontend:
Public IP

Frontend Port:
80

Backend Port:
80

Protocol:
TCP
```

Traffic flow:

```text
Client
  |
  | TCP 80
  v
Public IP
  |
  v
Load Balancer
  |
  v
Backend Pool
  |
  +--> VM1:80
  +--> VM2:80
  +--> VM3:80
```

### Definition

> A Load Balancing Rule maps frontend traffic to a backend pool and specifies how that traffic should be distributed.

---

# 13. Backend Port

The backend port is the port on which the application is listening on backend resources.

Example:

```text
Frontend Port = 80
Backend Port  = 80
```

Traffic:

```text
Client
  |
  v
LB:80
  |
  v
VM:80
```

The frontend and backend ports can also be different depending on the configuration.

---

# 14. Protocol

Load Balancer operates at Layer 4 and supports network protocols such as:

```text
TCP
UDP
```

Example:

```text
TCP Port 80
TCP Port 443
UDP Port 53
```

It does not provide application-layer HTTP routing like an Application Gateway.

---

# 15. Layer 4 Load Balancing

Azure Load Balancer works at:

```text
OSI Layer 4
Transport Layer
```

It primarily works with:

```text
TCP
UDP
```

It does not inspect application-level HTTP content in the same way as Layer 7 services.

---

# 16. Load Balancer Traffic Flow

A typical request flow is:

```text
              Client
                 |
                 v
            Public IP
                 |
                 v
         Azure Load Balancer
                 |
          Load Balancing Rule
                 |
                 v
           Backend Pool
          /      |      \
         v       v       v
       VM-1    VM-2    VM-3
```

The Load Balancer uses the configured rules and health probes to determine where traffic should go.

---

# 17. Dependencies

A basic Azure Load Balancer architecture can depend on the following resources:

```text
Resource Group
      |
      +-- Public IP
      |
      +-- Load Balancer
              |
              +-- Frontend IP
              |
              +-- Backend Pool
              |
              +-- Health Probe
              |
              +-- Load Balancing Rule
```

For a working application architecture, you normally also need:

```text
Virtual Network
      |
      +-- Subnet
             |
             +-- VM / VMSS
                    |
                    +-- NIC
```

---

# 18. Dependency Order

A common deployment order is:

```text
1. Resource Group
       |
       v
2. Virtual Network
       |
       v
3. Subnet
       |
       v
4. Network Interface
       |
       v
5. Virtual Machine
       |
       v
6. Public IP
       |
       v
7. Load Balancer
       |
       v
8. Backend Pool
       |
       v
9. Health Probe
       |
       v
10. Load Balancing Rule
```

The exact dependency order can vary depending on the architecture.

---

# 19. Your Current Terraform Configuration

Your current configuration creates three main resources:

```text
Resource Group
      |
      +-- Public IP
      |
      +-- Load Balancer
```

Your configuration currently contains:

```hcl
azurerm_resource_group
azurerm_public_ip
azurerm_lb
```

It creates:

```text
Resource Group
      |
      +-- Public IP
      |
      +-- Load Balancer
```

### Important

Your current code creates the Load Balancer and its frontend Public IP configuration, but it does **not yet define a backend pool, health probe, or load-balancing rule**.

Therefore, this is not yet a complete traffic-distribution setup.

---

# 20. Complete Load Balancer Architecture

A complete basic architecture looks like:

```text
                         Internet
                            |
                            v
                     Public IP Address
                            |
                            v
                  +--------------------+
                  | Azure Load         |
                  | Balancer           |
                  +--------------------+
                     |       |       |
                     |       |       |
                     v       v       v
                  Backend Backend Backend
                   VM-1     VM-2     VM-3
                     |       |       |
                     +-------+-------+
                             |
                       Health Probe
```

---

# 21. Inbound NAT Rule

An **Inbound NAT Rule** allows traffic from a Load Balancer frontend port to be forwarded to a specific backend VM.

Example:

```text
Public IP
    |
    | Port 50001
    v
Load Balancer
    |
    | Port 22
    v
VM-1
```

This can be useful for administrative access to a specific backend VM.

### Definition

> Inbound NAT provides port translation from the Load Balancer frontend to a specific backend resource.

---

# 22. Outbound Connectivity

Azure Load Balancer can also provide outbound connectivity for backend resources depending on the architecture and configuration.

Example:

```text
VM
 |
 v
Load Balancer
 |
 v
Internet
```

Outbound rules can define how backend instances access external destinations.

---

# 23. Public vs Internal Load Balancer

Azure Load Balancer can be used in two broad scenarios:

## Public Load Balancer

Used when traffic comes from the Internet.

```text
Internet
   |
   v
Public Load Balancer
   |
   v
Backend VMs
```

## Internal Load Balancer

Used for private/internal traffic.

```text
Internal Client
      |
      v
Internal Load Balancer
      |
      v
Backend VMs
```

An internal Load Balancer uses a private frontend IP.

---

# 24. Public Load Balancer Use Case

Example:

```text
Internet
    |
    v
Public IP
    |
    v
Load Balancer
   / \
  v   v
VM1  VM2
```

Used for applications that need to accept Internet traffic.

Examples:

* Web servers
* Public APIs
* Internet-facing applications

---

# 25. Internal Load Balancer Use Case

Example:

```text
Frontend Application
        |
        v
Internal Load Balancer
        |
        v
Backend Application
      /   \
     v     v
   VM1    VM2
```

Used for internal application tiers.

Example:

```text
Web Tier
   |
   v
Internal Load Balancer
   |
   v
Application Tier
```

---

# 26. Load Balancer vs Application Gateway

These services are different.

| Feature                  | Azure Load Balancer | Application Gateway     |
| ------------------------ | ------------------- | ----------------------- |
| OSI Layer                | Layer 4             | Layer 7                 |
| Protocol                 | TCP/UDP             | HTTP/HTTPS              |
| URL-based routing        | No                  | Yes                     |
| Host-based routing       | No                  | Yes                     |
| Web Application Firewall | No                  | Available               |
| TCP load balancing       | Yes                 | Not its primary purpose |
| HTTP-aware routing       | No                  | Yes                     |

### Easy Interview Answer

> **Load Balancer is Layer 4, while Application Gateway is Layer 7.**

---

# 27. Load Balancer vs Traffic Manager

| Load Balancer                            | Traffic Manager              |
| ---------------------------------------- | ---------------------------- |
| Layer 4                                  | DNS-based                    |
| Distributes traffic to backend resources | Directs clients to endpoints |
| Regional load balancing                  | Global traffic distribution  |
| TCP/UDP                                  | DNS                          |
| Azure networking service                 | DNS traffic-routing service  |

---

# 28. Load Balancer vs Front Door

| Load Balancer          | Azure Front Door              |
| ---------------------- | ----------------------------- |
| Layer 4                | Layer 7                       |
| Regional networking    | Global application delivery   |
| TCP/UDP                | HTTP/HTTPS                    |
| Network traffic        | Web/application traffic       |
| Backend load balancing | Global routing + acceleration |

---

# 29. Advantages

## 29.1 High Availability

Traffic can be distributed across multiple backend resources.

```text
       Load Balancer
        /        \
      VM1        VM2
```

If one backend becomes unavailable, another backend can continue serving traffic.

---

## 29.2 Scalability

Additional backend resources can be added as application demand increases.

```text
Before:

LB
 |
 +-- VM1
 +-- VM2


After:

LB
 |
 +-- VM1
 +-- VM2
 +-- VM3
 +-- VM4
```

---

## 29.3 Fault Tolerance

Health probes help prevent traffic from being sent to unhealthy backend instances.

---

## 29.4 Traffic Distribution

Incoming traffic can be distributed across multiple backend resources.

---

## 29.5 Flexible Architecture

Can be used for:

* Public applications
* Internal applications
* Web tiers
* Application tiers
* VM-based workloads
* VM Scale Sets

---

# 30. Limitations

Azure Load Balancer is not a complete application security service.

It does not replace:

* Web Application Firewall
* Network Security Groups
* Azure Firewall
* DDoS protection services
* Application Gateway

It is primarily a network load-balancing service.

---

# 31. Security Considerations

When using a Load Balancer, consider:

```text
Internet
   |
   v
Public Load Balancer
   |
   v
NSG
   |
   v
Backend VM
```

You should ensure that:

* Required ports are allowed
* Unnecessary ports are blocked
* NSG rules are configured correctly
* Backend applications are listening on the expected ports
* Health probes can reach the required port
* Administrative access is properly secured

---

# 32. Health Probe Troubleshooting

If the backend is marked unhealthy, check:

### 1. Is the application running?

Example:

```text
Web Server = Running
```

### 2. Is the application listening on the correct port?

Example:

```text
Port 80 = Listening
```

### 3. Is the NSG allowing the required traffic?

### 4. Is the health probe configured for the correct protocol and port?

### 5. Is the backend NIC correctly configured?

---

# 33. Common Problems

## Problem 1: Backend is Unhealthy

Possible causes:

```text
Application stopped
       OR
Wrong port
       OR
NSG blocking traffic
       OR
Incorrect health probe
```

---

## Problem 2: Load Balancer Is Not Reachable

Check:

```text
Public IP
     |
     v
Frontend configuration
     |
     v
Load balancing rule
     |
     v
Backend pool
     |
     v
Health probe
```

---

## Problem 3: Traffic Is Not Reaching VM

Check:

```text
Client
 |
 v
Public IP
 |
 v
Frontend
 |
 v
Load Balancing Rule
 |
 v
Backend Pool
 |
 v
Health Probe
 |
 v
VM
 |
 v
Application
```

Find where the flow stops.

---

# 34. Terraform Resource Dependencies

Common Terraform resources for a complete Load Balancer deployment include:

```text
azurerm_resource_group
azurerm_virtual_network
azurerm_subnet
azurerm_public_ip
azurerm_lb
azurerm_lb_backend_address_pool
azurerm_lb_probe
azurerm_lb_rule
azurerm_network_interface_backend_address_pool_association
```

Depending on the design, you may also use:

```text
azurerm_lb_nat_rule
azurerm_lb_outbound_rule
azurerm_lb_nat_pool
```

---

# 35. Terraform Dependency Concept

Terraform automatically creates dependencies when one resource references another.

Example:

```hcl
location = azurerm_resource_group.rg-block.location
```

This creates a dependency on:

```text
Resource Group
       |
       v
Public IP
```

Similarly:

```hcl
public_ip_address_id = azurerm_public_ip.pip-block.id
```

creates:

```text
Public IP
    |
    v
Load Balancer
```

Terraform can therefore determine the appropriate resource creation order.

---

# 36. Terraform Workflow

Typical Terraform workflow:

```text
Write Terraform Code
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
        |
        v
Azure Resources Created
```

---

# 37. Terraform Commands

### Initialize

```powershell
terraform init
```

Downloads and initializes the required provider.

---

### Validate

```powershell
terraform validate
```

Checks whether the Terraform configuration is syntactically and structurally valid.

---

### Format

```powershell
terraform fmt
```

Formats Terraform configuration files.

---

### Plan

```powershell
terraform plan
```

Shows what Terraform plans to create, modify, or destroy.

---

### Apply

```powershell
terraform apply
```

Creates or changes Azure resources according to the Terraform configuration.

---

### Destroy

```powershell
terraform destroy
```

Deletes resources managed by the Terraform configuration.

---

# 38. Important Architecture

Remember this basic structure:

```text
                  CLIENT
                    |
                    v
              FRONTEND IP
                    |
                    v
            AZURE LOAD BALANCER
                    |
             LOAD BALANCING RULE
                    |
                    v
              BACKEND POOL
              /     |     \
             v      v      v
           VM-1   VM-2   VM-3
             |      |      |
             +------+------+ 
                    |
               HEALTH PROBE
```

---

# 39. What Happens When a VM Fails?

Suppose:

```text
VM1 = Healthy
VM2 = Healthy
VM3 = Unhealthy
```

The Load Balancer can distribute traffic to:

```text
VM1
VM2
```

and avoid:

```text
VM3
```

until the backend becomes healthy again.

---

# 40. Important Terms

### Frontend IP

The IP address clients connect to.

### Backend Pool

Collection of backend resources.

### Health Probe

Checks backend health.

### Load Balancing Rule

Defines how frontend traffic reaches the backend pool.

### Backend Port

Port on which the backend application receives traffic.

### Frontend Port

Port exposed by the Load Balancer.

### Inbound NAT

Maps frontend traffic to a specific backend resource.

### Outbound Rule

Controls outbound connectivity from backend instances.

---

# 41. Simple Example

Imagine:

```text
Public IP:
20.x.x.x

Frontend Port:
80

Backend Port:
80

Backend:
VM1
VM2
VM3
```

Traffic:

```text
User
 |
 | http://20.x.x.x
 |
 v
Load Balancer
 |
 +----> VM1:80
 |
 +----> VM2:80
 |
 +----> VM3:80
```

The Load Balancer distributes traffic according to its configured rule and backend health.

---

# 42. Advantages Summary

```text
+ High Availability
+ Scalability
+ Fault Tolerance
+ Traffic Distribution
+ Health Monitoring
+ Public and Internal Load Balancing
+ Supports TCP/UDP
+ Integrates with Azure networking
+ Works with VMs and VM Scale Sets
```

---

# 43. Limitations Summary

```text
- Layer 4 service
- No URL-based routing
- No host-based HTTP routing
- Not a Web Application Firewall
- Does not replace NSG
- Does not replace Azure Firewall
- Requires correct backend and health-probe configuration
```

---

# 44. Interview Questions

## Q1. What is Azure Load Balancer?

> Azure Load Balancer is a Layer 4 service that distributes TCP/UDP traffic across backend resources.

---

## Q2. What is the purpose of a Load Balancer?

> It improves availability, scalability, and fault tolerance by distributing traffic across multiple backend resources.

---

## Q3. What is a frontend IP?

> It is the IP address through which clients access the Load Balancer.

---

## Q4. What is a backend pool?

> It is a collection of backend resources that receive traffic from the Load Balancer.

---

## Q5. What is a health probe?

> A health probe checks whether backend resources are healthy before traffic is sent to them.

---

## Q6. What is a Load Balancing Rule?

> It defines how traffic received on the frontend is distributed to the backend pool.

---

## Q7. What OSI layer does Azure Load Balancer operate at?

> Azure Load Balancer operates at Layer 4, the Transport Layer.

---

## Q8. Which protocols does Azure Load Balancer support?

> It supports TCP and UDP traffic.

---

## Q9. What is the difference between Public and Internal Load Balancer?

> A Public Load Balancer uses a public frontend IP for Internet-facing traffic, while an Internal Load Balancer uses a private frontend IP for internal network traffic.

---

## Q10. Does a Load Balancer replace a firewall?

> No. A Load Balancer distributes network traffic; it is not a replacement for a firewall or WAF.

---

## Q11. What happens when a backend VM becomes unhealthy?

> The health probe detects the unhealthy backend, and the Load Balancer stops sending new traffic to that backend while it remains unhealthy.

---

## Q12. What is the difference between Load Balancer and Application Gateway?

> Load Balancer is Layer 4 and handles TCP/UDP traffic, while Application Gateway is Layer 7 and provides HTTP/HTTPS-aware features such as URL-based routing.

---

# 45. Easy Memory Trick

Remember these four components:

```text
F - Frontend
B - Backend
P - Probe
R - Rule
```

### F → Frontend

**Where does traffic come in?**

### B → Backend

**Where should traffic go?**

### P → Probe

**Is the backend healthy?**

### R → Rule

**How should traffic be distributed?**

So:

```text
Frontend
    |
    v
  Rule
    |
    v
Backend Pool
    |
    v
  Probe
    |
    v
Healthy Backend
```

---

# 46. Final Summary

Azure Load Balancer provides Layer 4 network load balancing in Azure.

The basic architecture is:

```text
                       CLIENT
                         |
                         v
                    FRONTEND IP
                         |
                         v
                 AZURE LOAD BALANCER
                         |
                         v
                LOAD BALANCING RULE
                         |
                         v
                   BACKEND POOL
                  /      |      \
                 v       v       v
               VM-1    VM-2    VM-3
                 ^       ^       ^
                 |       |       |
                 +-------+-------+
                     HEALTH PROBE
```

### Remember:

> **Frontend receives traffic.**

> **Rule decides how traffic is forwarded.**

> **Backend Pool contains the servers.**

> **Health Probe checks server health.**

> **Load Balancer distributes the traffic.**

And the easiest interview statement:

> **Azure Load Balancer is a Layer 4 service that distributes TCP/UDP traffic across healthy backend resources to provide high availability and scalability.**
