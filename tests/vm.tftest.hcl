mock_provider "azurerm" {}

variables {
  prefix      = "test"
  index       = 1
  rg_location = "westeurope"
  rg_name     = "rg-test"

  vm_size        = "Standard_B2s"
  admin_username = "azureuser"

  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWViappg/uQDtKT/OM3MnzH/H/pl8El1bLF4puTno5e52Er2TkvilNUQnIXtrUcOWrUAR/QnrOIUl+FkZb+fE1YM3WvOUX1hwKe/WoIpCaxOk2ffDnmdd+6f5rjR/y3qHRJqr2i+iPKzdqVAZJeaGmTU3ZCmTFy3oDHNV6/lVclha4rXdhGyBvo++IuPFt9kxMJHacxc1YvKODpe0pkDnYtiw7K3K+2bQ0B9eOlKQka0qnNkX5Sn7NdFp+bdAudYJvqjSWka89A/CyhjfhOUflmsy/5kNsiNdjt2r0+8fGcnwYM98S3AytKB5DX+C9cccBbBWyM1W37WBz/xBwv4Dp terraform-test"

  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Standard_LRS"

  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts"
  image_version   = "latest"

  ssh_allowed_cidr = "10.0.0.0/8"

  subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/test-vnet-demo/subnets/test-subnet-demo"
}

run "vm_creates_linux_vm_with_expected_settings" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.name == "test-vm-demo-1"
    error_message = "VM name should be prefixed and include index"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.resource_group_name == "rg-test"
    error_message = "VM resource group should be set"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.location == "westeurope"
    error_message = "VM location should be set"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.size == "Standard_B2s"
    error_message = "VM size should be passed through"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.admin_username == "azureuser"
    error_message = "Admin username should be passed through"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.disable_password_authentication == true
    error_message = "Password authentication must be disabled"
  }

  assert {
    condition = anytrue([
      for k in azurerm_linux_virtual_machine.vm.admin_ssh_key :
      k.username == "azureuser"
    ])
    error_message = "admin_ssh_key must contain entry with correct username"
  }

  assert {
    condition = anytrue([
      for k in azurerm_linux_virtual_machine.vm.admin_ssh_key :
      length(k.public_key) > 0
    ])
    error_message = "admin_ssh_key must contain non-empty public_key"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].caching == "ReadWrite"
    error_message = "OS disk caching should be passed through"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].storage_account_type == "Standard_LRS"
    error_message = "OS disk storage account type should be passed through"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.source_image_reference[0].publisher == "Canonical"
    error_message = "Image publisher should be passed through"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.source_image_reference[0].offer == "0001-com-ubuntu-server-jammy"
    error_message = "Image offer should be passed through"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.source_image_reference[0].sku == "22_04-lts"
    error_message = "Image sku should be passed through"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.source_image_reference[0].version == "latest"
    error_message = "Image version should be passed through"
  }
}

run "vm_size_validation_rejects_non_standard" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    vm_size = "B2s"
  }

  expect_failures = [
    var.vm_size,
  ]
}

run "admin_username_validation_rejects_reserved_names" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    admin_username = "root"
  }

  expect_failures = [
    var.admin_username,
  ]
}

run "ssh_key_validation_rejects_empty_key" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_public_key = ""
  }

  expect_failures = [
    var.ssh_public_key,
  ]
}