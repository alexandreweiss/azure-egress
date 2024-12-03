
resource "azurerm_subnet" "subnet-monitoring" {
  name                 = "subnet-200"
  address_prefixes     = [cidrsubnet(var.lab_cidr, 8, 200)]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "template_file" "monitoring_vm_config" {
  template = file("${path.module}/monitoring-vm-config.tftpl")

  vars = {
    ip_addresses = join(",", "${module.vm[*].vm_private_ip}")
  }
}

module "monitoring_vm" {
  source = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"

  environment         = "monitoring"
  location            = var.location
  location_short      = var.location_short
  index_number        = "0"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet-monitoring.id
  custom_data         = base64encode(data.template_file.monitoring_vm_config.rendered)
  admin_ssh_key       = var.admin_ssh_key
  customer_name       = "lab"
  enable_public_ip    = true
  depends_on = [
  ]
}

resource "azurerm_network_security_rule" "monitoring_http" {
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
  network_security_group_name = module.monitoring_vm.nsg_name
}

resource "azurerm_network_security_rule" "monitoring_ssh" {
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
  network_security_group_name = module.monitoring_vm.nsg_name
}
