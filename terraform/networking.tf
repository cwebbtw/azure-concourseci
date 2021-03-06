
resource "azurerm_virtual_network" "concourse_vnet" {
  name                = "concourse-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"
}

resource "azurerm_subnet" "concourse_public_subnet" {
  name                 = "concourse-public-subnet"
  resource_group_name  = "${azurerm_resource_group.concourse.name}"
  virtual_network_name = "${azurerm_virtual_network.concourse_vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "concourse_public_nic" {
  name                = "concourse-public-nic"
  location            = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"

  ip_configuration {
    name                          = "concourse-public-nic"
    subnet_id                     = "${azurerm_subnet.concourse_public_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.concourse_public_ip.id}"
  }
}

resource "azurerm_public_ip" "concourse_public_ip" {
  location                     = "${azurerm_resource_group.concourse.location}"
  resource_group_name          = "${azurerm_resource_group.concourse.name}"
  allocation_method            = "Dynamic"
  name                         = "concourse-public-ip"
  domain_name_label            = "${var.public_ip_label}"
}

resource "azurerm_network_interface_application_security_group_association" "concourse_asg_association" {
  network_interface_id          = "${azurerm_network_interface.concourse_public_nic.id}"
  ip_configuration_name         = "${azurerm_network_interface.concourse_public_nic.ip_configuration.0.name}"
  application_security_group_id = "${azurerm_application_security_group.concourse_asg.id}"
}

resource "azurerm_application_security_group" "concourse_asg" {
  name                = "concourse-asg"
  location            = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"
}

resource "azurerm_network_security_group" "concourse_nsg" {
  name                = "concourse-nsg"
  location            = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_application_security_group_ids = ["${azurerm_application_security_group.concourse_asg.id}"]
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_application_security_group_ids = ["${azurerm_application_security_group.concourse_asg.id}"]
  }
}
