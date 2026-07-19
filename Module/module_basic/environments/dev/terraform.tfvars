rg_name  = "module_1_rg"
location = "centralindia"

vnet_name = "module_vnet"

vnet_addspace        = ["10.0.0.0/16"]
subnet_address_space = ["10.0.0.0/24"]
subnets = {
  frontend = ["10.0.1.0/24"]
  backend  = ["10.0.2.0/24"]
  database = ["10.0.3.0/24"]
}