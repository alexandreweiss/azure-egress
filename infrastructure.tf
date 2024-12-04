data "azurerm_subscription" "current" {
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

resource "random_integer" "random" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.location_short}-lab-${random_integer.random.result}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.lab_cidr]
  location            = var.location
  name                = "${var.location_short}-lab-vn"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  count = var.subnet_count

  name                 = "subnet-${count.index}"
  address_prefixes     = [cidrsubnet(var.lab_cidr, 8, count.index)]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "template_file" "test_vm_config" {
  template = file("${path.module}/test-vm-config.tftpl")

  vars = {
  }
}

module "vm" {
  source = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  count  = var.subnet_count

  environment         = "test"
  location            = var.location
  location_short      = var.location_short
  index_number        = count.index
  resource_group_name = azurerm_resource_group.rg.name
  custom_data         = base64encode(data.template_file.test_vm_config.rendered)
  subnet_id           = azurerm_subnet.subnet[count.index].id
  admin_ssh_key       = var.admin_ssh_key
  customer_name       = "lab"
  depends_on = [
  ]
}

# Nat gateway subnet-0
module "nat_gw" {
  source = "github.com/alexandreweiss/misc-tf-modules/nat-gateway"

  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  nat_gateway_name    = "${var.location_short}-nat-gw"
}

resource "azurerm_subnet_nat_gateway_association" "nat_gw_association_0" {
  nat_gateway_id = module.nat_gw.nat_gateway.id
  subnet_id      = azurerm_subnet.subnet[0].id
}


# Blackhole subnet-1
resource "azurerm_route_table" "subnet-1-rt" {
  location            = var.location
  name                = "${var.location_short}-subnet-1-rt"
  resource_group_name = azurerm_resource_group.rg.name

  route {
    address_prefix = "0.0.0.0/0"
    name           = "internetDefaultBlackhole"
    next_hop_type  = "None"
  }

  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

resource "azurerm_subnet_route_table_association" "subnet-1-rt-assoc" {
  route_table_id = azurerm_route_table.subnet-1-rt.id
  subnet_id      = azurerm_subnet.subnet[1].id
  depends_on     = [module.vm]
}


