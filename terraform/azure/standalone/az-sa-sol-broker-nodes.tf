####################################################################################################
# INSTRUCTIONS:
# (1) Customize these instance values to your preference.  
#       * instance: 
#         - size
#         - zone (Availability Zone)
#       * Ultra disk usage & configs - UNCOMMENT config properties on the Az Resources:
#         - azurerm_linux_virtual_machine
#         - azurerm_managed_disk
#         - azurerm_virtual_machine_data_disk_attachment
#       * tags
# (2) On the Ansible Playbooks & Var files - Adjust the PubSub+ SW Broker:
#         - Scaling tier 
#         - external storage device name - ex: /dev/sdc or /dev/xvdc
#         - Docker Version
#         - Solace Image Type, Standard, Enterprise or Enterprise Eval
#     according to the VM size/type
# (3) Make sure the account you're running terraform with has proper permissions in your Azure env
####################################################################################################

resource "azurerm_linux_virtual_machine" "solace-broker-nodes" {

  count = var.solace_broker_count
  
  name                   = "${var.tag_name_prefix}-solacebroker-node-${count.index}"
  #If a Resource Group was specified we'll query its Location and use it, otherwise use the location of the Res Group that was just created
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  admin_username         = var.az_admin_username
  network_interface_ids  = [azurerm_network_interface.solacebroker-nodes-nic[count.index].id]
#  size                   = "Standard_DS2_v2"   # (2 cpus  7G Ram, Max  6400 IOPs  96 MB/s - General Purpose VM)
  size                   = "Standard_D2s_v3"   # (2 cpus  8G Ram, Max  3200 IOPs  48 MB/s - General Purpose VM)
#  size                   = "Standard_DS3_v2"   # (4 cpus 14G Ram, Max 12800 IOPs 192 MB/s - General Purpose VM)
#  size                   = "Standard_D4s_v3"   # (4 cpus 16G Ram, Max 6400 IOPs 96 MB/s - General Purpose VM) - Supports Ultradisks
#  size                   = "Standard_F4s_v2"    # (4 cpus  8G Ram, Max  6400 IOPs  95 MB/s - Compute Optimized VM)
#  size                   = "Standard_L4s"       # (4 cpus  32G Ram, Max  5000 IOPs  ?? MB/s - Storage Optimized VM)
#  zone                   = 2

#NOTE: "ultra_ssd_enabled" HAS to be set when using UltraSSD_LRS data disks
  additional_capabilities {
#    ultra_ssd_enabled      = true
    ultra_ssd_enabled     = false
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = "7.7"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.tag_name_prefix}-solacebroker-node-${count.index}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = var.az_admin_username
    public_key = file(var.public_key_path)
  }

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - Broker node"
    Days    = var.tag_days
  }

# Do not flag the azurerm_linux_virtual_machine resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = ["echo 'SSH ready to rock'"]

    connection {
      host        = self.public_ip_address
      type        = "ssh"
      user        = var.az_admin_username
      private_key = file(var.private_key_path)
    }
  }
}

resource "azurerm_managed_disk" "solace-broker-datadisk" {
  count = var.solace_broker_count

  name                 = "${var.tag_name_prefix}-solacebroker-node-${count.index}-datadisk"
  location             = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name  = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  create_option        = "Empty"
  disk_size_gb         = var.solacebroker_storage_size

  storage_account_type = "Premium_LRS"

#NOTE: "disk_iops_read_write" & "disk_mbps_read_write" Can only (and HAVE to...) be set when using UltraSSD_LRS data disks, 
#Otherwhise these options should be commented
#  storage_account_type = "UltraSSD_LRS"
#  disk_iops_read_write = "35000"
#  disk_mbps_read_write = "2000"

#  zones                  = [ 2 ]

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-node-${count.index}-datadisk"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - Broker node Data Disk"
    Days    = var.tag_days
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "solace-broker-datadisk-attach" {
  count = var.solace_broker_count

  managed_disk_id    = azurerm_managed_disk.solace-broker-datadisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.solace-broker-nodes[count.index].id
  lun                = "0"
#NOTE: Set "caching" to None when using UltraSSD_LRS data disks
#  caching            = "ReadWrite"
#  caching            = "ReadOnly"
  caching            = "None"
}

resource "azurerm_network_interface" "solacebroker-nodes-nic" {
  count = var.solace_broker_count

  name                   = "${var.tag_name_prefix}-solacebroker-nic-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id == "" ? azurerm_subnet.sdkperf_subnet[0].id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.solacebroker-nodes-pubip[count.index].id
  }

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-nic-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - solace broker node nic"
    Days    = var.tag_days
  }  
}

resource "azurerm_public_ip" "solacebroker-nodes-pubip" {
  count = var.solace_broker_count

  name                = "${var.tag_name_prefix}-solacebroker-pubip-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

#  allocation_method      = "Dynamic"
#  sku                    = "Basic"
  allocation_method      = "Static"
  sku                    = "Standard"
#  zones                  = [ 2 ]

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-pubip-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - solacebroker node pubip"
    Days    = var.tag_days
  }
}

#Asociate the VM NIC to the Sec Group created
resource "azurerm_network_interface_security_group_association" "solacebroker-nodes-secgrp_association" {
  count = var.solace_broker_count

  network_interface_id      = azurerm_network_interface.solacebroker-nodes-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.solacebroker_secgrp.id
}

resource "local_file" "solacebroker_inv_file" {
  content = templatefile("../../templates/inventory/sa-sol-broker-nodes.tpl",
    {
      solacebroker-nodes-ips = azurerm_linux_virtual_machine.solace-broker-nodes.*.public_ip_address
    }
  )
  filename = "../../../ansible/inventory/az-sa-sol-broker-nodes.inventory"
}

resource "local_file" "start-sdkperf-c-pub" {
  count = var.solace_broker_count > "0" ? 1 : 0  

  content = templatefile("../../templates/playbooks/start-sdkperf-c-pub.tpl",
    {
      solacebroker-node-ips = azurerm_linux_virtual_machine.solace-broker-nodes.*.private_ip_address
    }
  )
  filename = "../../../ansible/playbooks/sdkperf/az-sa-start-sdkperf-c-pub.yml"
}

resource "local_file" "start-sdkperf-c-qcons" {
  count = var.solace_broker_count > "0" ? 1 : 0
  
  content = templatefile("../../templates/playbooks/start-sdkperf-c-qcons.tpl",
    {
      solacebroker-node-ips = azurerm_linux_virtual_machine.solace-broker-nodes.*.private_ip_address
    }
  )
  filename = "../../../ansible/playbooks/sdkperf/az-sa-start-sdkperf-c-qcons.yml"
}

# Trigger Ansible Tasks for the Brokers - Only after all the VM resources and Ansible Inventories & Playbooks have been created
resource "null_resource" "trigger_broker_ansible" {
  provisioner "local-exec" {
    #command = "echo 'trigger_ansible!! - ${local_file.solacebroker_inv_file.filename}'"
    command = "ansible-playbook -i ${local_file.solacebroker_inv_file.filename} --private-key ${var.private_key_path} ../../../ansible/playbooks/bootstrap/az-sa-sol-broker-centosnodes.yml"
  }

  depends_on = [
      local_file.solacebroker_inv_file,
      azurerm_virtual_machine_data_disk_attachment.solace-broker-datadisk-attach, # Disk allocation to an Azure VM happens after the VM creation, therefore we have to explicitly wait  
      local_file.solace_vars_loop_queues # Dependency to create Queues on the broker(s) based on the number of SDKPerf nodes created
    ]
}

