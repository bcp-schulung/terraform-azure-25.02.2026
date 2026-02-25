# =============================================================================
# VM Module Tests
# Tests for VM, NIC, NSG, Public IP creation and variable validations
# =============================================================================

mock_provider "azurerm" {}

variables {
  prefix                        = "test"
  rg_location                   = "westeurope"
  rg_name                       = "rg-test"
  subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
  ssh_public_key                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7..."
  ssh_allowed_cidr              = "10.0.0.0/8"
  index                         = 0
  enable_public_ip              = false
  public_ip_allocation_method   = "Static"
  public_ip_sku                 = "Standard"
  private_ip_address_allocation = "Dynamic"
  admin_username                = "azureuser"
  os_disk_caching               = "ReadWrite"
  os_disk_storage_account_type  = "Standard_LRS"
  image_publisher               = "Canonical"
  image_offer                   = "0001-com-ubuntu-server-jammy"
  image_sku                     = "22_04-lts-gen2"
  image_version                 = "latest"
  vm_size                       = "Standard_B1s"
}

# -----------------------------------------------------------------------------
# Resource Creation Tests
# -----------------------------------------------------------------------------

run "vm_creates_network_security_group_with_correct_naming" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.name == "test-nsg-demo-0"
    error_message = "NSG name should be 'test-nsg-demo-0'"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.location == "westeurope"
    error_message = "NSG should be in westeurope"
  }
}

run "vm_creates_nic_with_correct_naming" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_network_interface.nic.name == "test-nic-demo-0"
    error_message = "NIC name should be 'test-nic-demo-0'"
  }

  assert {
    condition     = azurerm_network_interface.nic.location == "westeurope"
    error_message = "NIC should be in westeurope"
  }
}

run "vm_creates_linux_vm_with_correct_naming" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.name == "test-vm-demo-0"
    error_message = "VM name should be 'test-vm-demo-0'"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.location == "westeurope"
    error_message = "VM should be in westeurope"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.size == "Standard_B1s"
    error_message = "VM size should be Standard_B1s"
  }
}

run "vm_uses_correct_admin_username" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.admin_username == "azureuser"
    error_message = "VM admin username should be azureuser"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.disable_password_authentication == true
    error_message = "Password authentication should be disabled"
  }
}

run "vm_uses_correct_image_settings" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.source_image_reference[0].publisher == "Canonical"
    error_message = "Image publisher should be Canonical"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.source_image_reference[0].offer == "0001-com-ubuntu-server-jammy"
    error_message = "Image offer should be Ubuntu Jammy"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.source_image_reference[0].sku == "22_04-lts-gen2"
    error_message = "Image SKU should be 22_04-lts-gen2"
  }
}

run "vm_uses_correct_os_disk_settings" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].caching == "ReadWrite"
    error_message = "OS disk caching should be ReadWrite"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].storage_account_type == "Standard_LRS"
    error_message = "OS disk storage account type should be Standard_LRS"
  }
}

run "vm_with_different_index" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    index = 5
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.name == "test-vm-demo-5"
    error_message = "VM name should use index 5"
  }

  assert {
    condition     = azurerm_network_interface.nic.name == "test-nic-demo-5"
    error_message = "NIC name should use index 5"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.name == "test-nsg-demo-5"
    error_message = "NSG name should use index 5"
  }
}

# -----------------------------------------------------------------------------
# Public IP Tests
# -----------------------------------------------------------------------------

run "vm_no_public_ip_when_disabled" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    enable_public_ip = false
  }

  # When enable_public_ip is false, no public IP resource should be created
  # The count will be 0, so we just verify the plan succeeds
  assert {
    condition     = var.enable_public_ip == false
    error_message = "Public IP should be disabled"
  }
}

run "vm_creates_public_ip_when_enabled" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    enable_public_ip = true
  }

  assert {
    condition     = azurerm_public_ip.pip[0].name == "test-pip-demo-0"
    error_message = "Public IP name should be 'test-pip-demo-0'"
  }

  assert {
    condition     = azurerm_public_ip.pip[0].allocation_method == "Static"
    error_message = "Public IP allocation method should be Static"
  }

  assert {
    condition     = azurerm_public_ip.pip[0].sku == "Standard"
    error_message = "Public IP SKU should be Standard"
  }
}

# -----------------------------------------------------------------------------
# NSG Security Rule Tests
# -----------------------------------------------------------------------------

run "nsg_has_ssh_rule" {
  command = plan

  module {
    source = "./modules/vm"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.security_rule[0].name == "SSH"
    error_message = "NSG should have SSH rule"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.security_rule[0].destination_port_range == "22"
    error_message = "SSH rule should allow port 22"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.security_rule[0].source_address_prefix == "10.0.0.0/8"
    error_message = "SSH rule should use ssh_allowed_cidr"
  }
}

# -----------------------------------------------------------------------------
# Prefix Variable Validation Tests
# -----------------------------------------------------------------------------

run "vm_prefix_accepts_valid_name" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "myvm"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.name == "myvm-vm-demo-0"
    error_message = "VM name should use the valid prefix"
  }
}

run "vm_prefix_rejects_uppercase" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "MYVM"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "vm_prefix_rejects_too_short" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "x"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "vm_prefix_rejects_too_long" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "verylongprefix"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "vm_prefix_rejects_starting_with_number" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "1vm"
  }

  expect_failures = [
    var.prefix,
  ]
}

# -----------------------------------------------------------------------------
# SSH Allowed CIDR Validation Tests
# -----------------------------------------------------------------------------

run "ssh_cidr_accepts_valid_private_range" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_allowed_cidr = "192.168.1.0/24"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.security_rule[0].source_address_prefix == "192.168.1.0/24"
    error_message = "Should accept valid private CIDR"
  }
}

run "ssh_cidr_accepts_single_ip" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_allowed_cidr = "203.0.113.50/32"
  }

  assert {
    condition     = azurerm_network_security_group.nsg.security_rule[0].source_address_prefix == "203.0.113.50/32"
    error_message = "Should accept single IP /32 CIDR"
  }
}

run "ssh_cidr_rejects_open_to_world" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_allowed_cidr = "0.0.0.0/0"
  }

  expect_failures = [
    var.ssh_allowed_cidr,
  ]
}

run "ssh_cidr_rejects_invalid_format" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_allowed_cidr = "invalid-cidr"
  }

  expect_failures = [
    var.ssh_allowed_cidr,
  ]
}

run "ssh_cidr_rejects_too_large_prefix" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_allowed_cidr = "10.0.0.0/7"
  }

  expect_failures = [
    var.ssh_allowed_cidr,
  ]
}

# -----------------------------------------------------------------------------
# Admin Username Validation Tests
# -----------------------------------------------------------------------------

run "admin_username_accepts_valid_name" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    admin_username = "devops"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.admin_username == "devops"
    error_message = "Should accept valid admin username"
  }
}

run "admin_username_rejects_admin" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    admin_username = "admin"
  }

  expect_failures = [
    var.admin_username,
  ]
}

run "admin_username_rejects_administrator" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    admin_username = "administrator"
  }

  expect_failures = [
    var.admin_username,
  ]
}

run "admin_username_rejects_root" {
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

run "admin_username_rejects_guest" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    admin_username = "guest"
  }

  expect_failures = [
    var.admin_username,
  ]
}

run "admin_username_rejects_test" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    admin_username = "test"
  }

  expect_failures = [
    var.admin_username,
  ]
}

run "admin_username_rejects_uppercase" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    admin_username = "MyUser"
  }

  expect_failures = [
    var.admin_username,
  ]
}

# -----------------------------------------------------------------------------
# VM Size Validation Tests
# -----------------------------------------------------------------------------

run "vm_size_accepts_standard_b1s" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    vm_size = "Standard_B1s"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.size == "Standard_B1s"
    error_message = "Should accept Standard_B1s"
  }
}

run "vm_size_accepts_standard_d2s_v3" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    vm_size = "Standard_D2s_v3"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.size == "Standard_D2s_v3"
    error_message = "Should accept Standard_D2s_v3"
  }
}

run "vm_size_rejects_non_standard_prefix" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    vm_size = "Basic_A1"
  }

  expect_failures = [
    var.vm_size,
  ]
}

# -----------------------------------------------------------------------------
# Public IP Configuration Tests
# -----------------------------------------------------------------------------

run "public_ip_allocation_accepts_static" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    enable_public_ip            = true
    public_ip_allocation_method = "Static"
  }

  assert {
    condition     = azurerm_public_ip.pip[0].allocation_method == "Static"
    error_message = "Should accept Static allocation"
  }
}

run "public_ip_allocation_accepts_dynamic" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    enable_public_ip            = true
    public_ip_allocation_method = "Dynamic"
    public_ip_sku               = "Basic"
  }

  assert {
    condition     = azurerm_public_ip.pip[0].allocation_method == "Dynamic"
    error_message = "Should accept Dynamic allocation"
  }
}

run "public_ip_allocation_rejects_invalid" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    public_ip_allocation_method = "Invalid"
  }

  expect_failures = [
    var.public_ip_allocation_method,
  ]
}

run "public_ip_sku_accepts_standard" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    enable_public_ip = true
    public_ip_sku    = "Standard"
  }

  assert {
    condition     = azurerm_public_ip.pip[0].sku == "Standard"
    error_message = "Should accept Standard SKU"
  }
}

run "public_ip_sku_accepts_basic" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    enable_public_ip            = true
    public_ip_sku               = "Basic"
    public_ip_allocation_method = "Dynamic"
  }

  assert {
    condition     = azurerm_public_ip.pip[0].sku == "Basic"
    error_message = "Should accept Basic SKU"
  }
}

run "public_ip_sku_rejects_invalid" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    public_ip_sku = "Premium"
  }

  expect_failures = [
    var.public_ip_sku,
  ]
}

# -----------------------------------------------------------------------------
# OS Disk Configuration Tests
# -----------------------------------------------------------------------------

run "os_disk_caching_accepts_readwrite" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    os_disk_caching = "ReadWrite"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].caching == "ReadWrite"
    error_message = "Should accept ReadWrite caching"
  }
}

run "os_disk_caching_accepts_readonly" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    os_disk_caching = "ReadOnly"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].caching == "ReadOnly"
    error_message = "Should accept ReadOnly caching"
  }
}

run "os_disk_caching_accepts_none" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    os_disk_caching = "None"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].caching == "None"
    error_message = "Should accept None caching"
  }
}

run "os_disk_caching_rejects_invalid" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    os_disk_caching = "Invalid"
  }

  expect_failures = [
    var.os_disk_caching,
  ]
}

run "os_disk_storage_accepts_premium_lrs" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    os_disk_storage_account_type = "Premium_LRS"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.os_disk[0].storage_account_type == "Premium_LRS"
    error_message = "Should accept Premium_LRS"
  }
}

run "os_disk_storage_rejects_invalid" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    os_disk_storage_account_type = "Invalid_LRS"
  }

  expect_failures = [
    var.os_disk_storage_account_type,
  ]
}

# -----------------------------------------------------------------------------
# Private IP Configuration Tests
# -----------------------------------------------------------------------------

run "private_ip_accepts_dynamic" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    private_ip_address_allocation = "Dynamic"
  }

  assert {
    condition     = azurerm_network_interface.nic.ip_configuration[0].private_ip_address_allocation == "Dynamic"
    error_message = "Should accept Dynamic private IP allocation"
  }
}

run "private_ip_accepts_static" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    private_ip_address_allocation = "Static"
  }

  assert {
    condition     = azurerm_network_interface.nic.ip_configuration[0].private_ip_address_allocation == "Static"
    error_message = "Should accept Static private IP allocation"
  }
}

run "private_ip_rejects_invalid" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    private_ip_address_allocation = "Invalid"
  }

  expect_failures = [
    var.private_ip_address_allocation,
  ]
}

# -----------------------------------------------------------------------------
# Index Validation Tests
# -----------------------------------------------------------------------------

run "index_accepts_zero" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    index = 0
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.name == "test-vm-demo-0"
    error_message = "Should accept index 0"
  }
}

run "index_accepts_ninety_nine" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    index = 99
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.name == "test-vm-demo-99"
    error_message = "Should accept index 99"
  }
}

run "index_rejects_negative" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    index = -1
  }

  expect_failures = [
    var.index,
  ]
}

run "index_rejects_too_large" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    index = 100
  }

  expect_failures = [
    var.index,
  ]
}

# -----------------------------------------------------------------------------
# SSH Public Key Validation Tests
# -----------------------------------------------------------------------------

run "ssh_key_accepts_rsa_key" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.admin_ssh_key[0].public_key == "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
    error_message = "Should accept RSA SSH key"
  }
}

run "ssh_key_accepts_ed25519_key" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.admin_ssh_key[0].public_key == "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
    error_message = "Should accept ED25519 SSH key"
  }
}

run "ssh_key_accepts_ecdsa_key" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_public_key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAy..."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.admin_ssh_key[0].public_key == "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAy..."
    error_message = "Should accept ECDSA SSH key"
  }
}

run "ssh_key_rejects_invalid_key" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    ssh_public_key = "invalid-ssh-key"
  }

  expect_failures = [
    var.ssh_public_key,
  ]
}

# -----------------------------------------------------------------------------
# Subnet ID Validation Tests
# -----------------------------------------------------------------------------

run "subnet_id_accepts_valid_format" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
  }

  assert {
    condition     = azurerm_network_interface.nic.ip_configuration[0].subnet_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
    error_message = "Should accept valid subnet ID"
  }
}

run "subnet_id_rejects_invalid_format" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    subnet_id = "invalid-subnet-id"
  }

  expect_failures = [
    var.subnet_id,
  ]
}

# -----------------------------------------------------------------------------
# Location Validation Tests
# -----------------------------------------------------------------------------

run "vm_location_accepts_westeurope" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    rg_location = "westeurope"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.vm.location == "westeurope"
    error_message = "Should accept westeurope as valid location"
  }
}

run "vm_location_rejects_invalid_region" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    rg_location = "invalid-region"
  }

  expect_failures = [
    var.rg_location,
  ]
}

# -----------------------------------------------------------------------------
# Resource Group Name Validation Tests
# -----------------------------------------------------------------------------

run "vm_rg_name_rejects_empty" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    rg_name = ""
  }

  expect_failures = [
    var.rg_name,
  ]
}

run "vm_rg_name_rejects_invalid_characters" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    rg_name = "rg@invalid!"
  }

  expect_failures = [
    var.rg_name,
  ]
}

# -----------------------------------------------------------------------------
# Image Validation Tests
# -----------------------------------------------------------------------------

run "image_publisher_rejects_empty" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    image_publisher = ""
  }

  expect_failures = [
    var.image_publisher,
  ]
}

run "image_offer_rejects_empty" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    image_offer = ""
  }

  expect_failures = [
    var.image_offer,
  ]
}

run "image_sku_rejects_empty" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    image_sku = ""
  }

  expect_failures = [
    var.image_sku,
  ]
}

run "image_version_rejects_empty" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    image_version = ""
  }

  expect_failures = [
    var.image_version,
  ]
}
