provider "azurerm" {
  version = "=1.22.0"
}

provider "azuread" {
  version = "=0.1.0"
  alias = "azuread"
}

resource "azurerm_resource_group" "concourse" {
  name     = "concourse"
  location = "westeurope"
}

resource "azurerm_virtual_network" "concourse_vnet" {
  name                = "concourse_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"
}

resource "azurerm_subnet" "concourse_public_subnet" {
  name                 = "concourse_public_subnet"
  resource_group_name  = "${azurerm_resource_group.concourse.name}"
  virtual_network_name = "${azurerm_virtual_network.concourse_vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "concourse_public_nic" {
  name                = "concourse_public_nic"
  location            = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"

  ip_configuration {
    name                          = "concourse_public_nic"
    subnet_id                     = "${azurerm_subnet.concourse_public_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.concourse_public_ip.id}"
  }
}

resource "azurerm_public_ip" "concourse_public_ip" {
  location                     = "${azurerm_resource_group.concourse.location}"
  resource_group_name          = "${azurerm_resource_group.concourse.name}"
  allocation_method            = "Dynamic"
  name                         = "concourse_public_ip"
}

resource "azurerm_network_security_group" "concourse_nsg" {
  name                = "concourse_nsg"
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
    destination_address_prefix = "*"
  }
}

resource "tls_private_key" "concourse_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_machine" "concourse_vm" {
  name = "concourse_vm"
  location = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"
  network_interface_ids = [
    "${azurerm_network_interface.concourse_public_nic.id}"]
  vm_size = "Standard_DS1_v2"

  storage_os_disk {
    name = "concourse_disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }

  os_profile {
    computer_name = "concourse"
    admin_username = "concourse"
    custom_data = "${data.template_cloudinit_config.concourse_config.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/concourse/.ssh/authorized_keys"
      key_data = "${tls_private_key.concourse_key.public_key_openssh}"
    }
  }
}

data "template_file" "concourse_config_template" {
  template = "${file("${path.root}/cloud-init/config.sh")}"
}

data "template_cloudinit_config" "concourse_config" {
  gzip          = true
  base64_encode = true

  part {
    content = "${data.template_file.concourse_config_template.rendered}"
  }
}

output "private_key" {
  value = "${tls_private_key.concourse_key.private_key_pem}"
}