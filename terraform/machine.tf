
resource "tls_private_key" "concourse_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_machine" "concourse_vm" {
  name = "concourse-vm"
  location = "${azurerm_resource_group.concourse.location}"
  resource_group_name = "${azurerm_resource_group.concourse.name}"
  network_interface_ids = [
    "${azurerm_network_interface.concourse_public_nic.id}"]
  vm_size = "Standard_DS1_v2"

  storage_os_disk {
    name = "concourse-disk"
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

  identity {
    type = "UserAssigned"
    identity_ids = ["${azurerm_user_assigned_identity.concourse_identity.id}"]
  }

  os_profile {
    computer_name = "concourse-all"
    admin_username = "admin"
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
  template = "${replace(file("${path.root}/cloud-init/config.sh"),
    "%EXTERNAL_URL%",
    "${var.public_ip_label}.${azurerm_resource_group.concourse.location}.cloudapp.azure.com")}"
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