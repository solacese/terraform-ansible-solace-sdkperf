####################################################################################################
# INSTRUCTIONS:
# (1) Customize these instance values to your preference.  
#       * instance_type
#       * availability_zone
#       * tags
# (2) Make sure the account you're running terraform with has proper permissions in your AWS env
####################################################################################################

resource "aws_instance" "sdkperf-nodes" {

  count = var.sdkperf_nodes_count
  
  ami                    = var.centOS_ami[var.aws_region]
  key_name               = var.aws_ssh_key_name
  subnet_id              = var.subnet_primary_id == "" ? aws_subnet.sdkperf_primary_subnet[0].id : var.subnet_primary_id
  vpc_security_group_ids = var.sdkperf_secgroup_ids == [""] ? ["${aws_security_group.sdkperf_secgroup[0].id}"] : var.sdkperf_secgroup_ids 

  instance_type          = var.sdkperf_vm_type
  availability_zone      = "${var.aws_region}a"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - sdkperf node"
    Days    = var.tag_days
  }

# Do not flag the aws_instance resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = ["echo 'SSH ready to rock'"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
    }
  }
}

resource "local_file" "sdkperf_inv_file" {
  content = templatefile("../../templates/inventory/sdkperf-nodes.tpl",
    {
      sdkperf_node_ips = aws_instance.sdkperf-nodes.*.public_ip
    }
  )
  filename = "../../../ansible/inventory/aws-ha-sdkperf-nodes.inventory"
}

resource "local_file" "solace_vars_loop_queues" {
  content = templatefile("../../templates/playbooks/vars/testvpn-sol-brokers-vars.tpl",
    {
      sdkperf_node_ips = aws_instance.sdkperf-nodes.*.private_ip
    }
  )
  filename = "../../../ansible/playbooks/bootstrap/vars/aws-ha-testvpn-sol-brokers-vars.yml"
}

# Trigger Ansible Tasks for the SDKPerf Nodes - Only after all the VM resources and Ansible Inventories & Playbooks have been created
resource "null_resource" "trigger_sdkperf_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ${local_file.sdkperf_inv_file.filename} --private-key ${var.private_key_path} ../../../ansible/playbooks/bootstrap/aws-sdkperf-centosnodes.yml"
  }
  depends_on = [local_file.sdkperf_inv_file]
}
