
resource "azurerm_subnet" "subnet-ilpip" {
  name                 = "subnet-198"
  address_prefixes     = [cidrsubnet(var.lab_cidr, 8, 198)]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "template_file" "ilpip_vm_config" {
  template = file("${path.module}/vm-ilpip-config.tftpl")

  vars = {
  }
}

module "ilpip_vm" {
  source = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"

  environment         = "ilpip"
  location            = var.location
  location_short      = var.location_short
  index_number        = "0"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet-ilpip.id
  custom_data         = base64encode(data.template_file.ilpip_vm_config.rendered)
  admin_ssh_key       = var.admin_ssh_key
  customer_name       = "lab"
  enable_public_ip    = true
  depends_on = [
  ]
}

resource "azurerm_network_security_rule" "ilpip_http" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = module.ilpip_vm.nsg_name
}

resource "azurerm_network_security_rule" "ilpip_ssh" {
  name                        = "Allow-SSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "81.49.43.155/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = module.ilpip_vm.nsg_name
}

# Blackhole subnet-198
resource "azurerm_route_table" "subnet-198-rt" {
  location            = var.location
  name                = "${var.location_short}-subnet-198-rt"
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

resource "azurerm_subnet_route_table_association" "subnet-198-rt-assoc" {
  route_table_id = azurerm_route_table.subnet-198-rt.id
  subnet_id      = azurerm_subnet.subnet-ilpip.id
  depends_on     = [module.ilpip_vm]
}
