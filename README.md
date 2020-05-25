# Solace - Terraform & Ansible automated deployment

## Overview

This repository is a collection of Terraform and Ansible configuration files that automatically provision the infrastructure required to run Solace Broker nodes as well as SDKPerf nodes.
This Repo is based on the [Benchmark Testing](https://github.com/andrew-j-roberts/sdkperf-automation) Repo, created by [Andrew Roberts](https://github.com/andrew-j-roberts)

### Warnings

> :warning: This project is intended to serve as a POC for demonstrating the automation capabilities of the Solace Brokers, as well as serving for Performance measuring. Therefore, there are several opportunities for improvement.    
> :warning: Keep in mind that this code has not been tested or coded to be PRODUCTION ready.

## Scripts Highlights 

**Depending on the selected Terraform scripts, they will allow you to:**:

- Provision N number of Solace PS+ Software Standalone event broker nodes
- Provision N number of Solace PS+ Software HA Clusters (AWS Only, Azure support under development)
- Provision N number of SDKPerf nodes
- Configure SDKPerf commands
- Execute your configured SDKPerf command on all your SDKPerf nodes
- Kill the SDKPerf processes on all your SDKPerf nodes
- Cleanup all the resources used in your test

> :information_source: On the Azure AWS & Azure Cloud
> :information_source: SDKPerf is a tool for validating performance, checking configuration, and exploring features associated with your Solace PubSub+ event broker. You can download it [here](https://solace.com/downloads/#other-software), or read our documentation on it [here](https://docs.solace.com/SDKPerf/SDKPerf.htm#contentBody).


**List of resources to be created by Terraform**:

+ Resource Group (If one is not provided - Azure only)
+ SSH Key Pair to log into the VMs (AWs Only)
+ Network VPC (If no subnet is specified)
+ Network Subnet, one for each HA node (If no subnet is specified)
+ Network Internet Gateway (AWs Only)
+ Network Route Table (AWs Only)
+ Security Group for the SDKPerf nodes
+ Security Group for the Solace Broker nodes
+ VM NIC (Azure only)
+ NIC Public IP (Azure only)
+ SDKPerf Nodes, Running CentOS 7.7
+ Solace Broker Nodes, Running CentOS 7.7 (Either Standalone or HA Configured Nodes)
+ Solace Broker Data External Disk (gp2 or Premium_LRS, io1 & UltraSSD_LRS can also be provisioned if needed)
+ Ansible Inventory File containing Public IPs for SDKPerfNodes
+ Ansible Inventory File containing Public IPs for Solace Brokers
+ Ansible Inventory File containing Private IPs for Solace Brokers (When creating HA nodes Only)
+ SDKPerf sample Ansible Playbook tests for the C SDKPerf
+ Ansible "Variables" (xx-xx-testvpn-sol-brokers-vars.yml) file containing Solace Configurations to be created on the Solace Broker, The Number of Queues will get created dynamically based on the number of SDKPerf Nodes
+ Resource Tags:  Name, Owner, Purpose & Days (When applicable)

**List of Tasks to be applied by Ansible at bootstrap**:

On SDKPerf nodes:

+ Enable SWAP on the VM 
+ Install OpenJDK (If required)
+ Copy the selected SDKPerf ex: sdkperf/sdkperf-c-x64

On Solace Broker nodes:

+ Enable SWAP on the VM 
+ Partition, Format & Mount external disk
+ Create & Assign permissions for the Broker folders on the external disk
+ Install Docker CE
+ Install docker-compose
+ Parse & upload docker-compose template according to the Solace Broker type (Standard, Enterprise or Enterprise Eval) & Node Role (Standalone, Primary, Backup or Monitor)
+ Copy Solace Broker Image to VM (Only for Enterprise or Enterprise Eval)
+ Load Solace Broker Image (Only for Enterprise or Enterprise Eval)
+ Create and Run Solace Docker container according to the created docker-compose file
+ Install performance monitoring tools on the OS: HTOP, sysstat (iostat)
+ Wait for SEMP to be ready
+ SEMP request to Assert Master Broker
+ SEMP request to update-broker-spoolsize
+ SEMP requests to create Solace configurations on the Solace Brokers


### Prerequisites

General

+ A control host that will run the Terraform & Ansible Scripts 
+ Install Terraform on the Host - Instructions [here](https://learn.hashicorp.com/terraform/getting-started/install.html)
+ Install Ansible on the host - Instructions [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
+ Disable host key checking by the underlying tools Ansible uses to connect to the host 
   ```
     export ANSIBLE_HOST_KEY_CHECKING=false
   ```

AWS

**Configure Terraform to use the credentials of a sufficiently privileged IAM role**  
   You can do this in a number of ways, but I recommend using environment variables as a quick, easy, and secure way of passing your keys to Terraform. Instructions [here](https://www.terraform.io/docs/providers/aws/index.html#environment-variables).
   ```
     export AWS_ACCESS_KEY_ID="accesskey"
     export AWS_SECRET_ACCESS_KEY="secretkey"
   ```

Azure

**Configure Terraform to use the credentials of a sufficiently privileged IAM role**  
   The easiest approach is to create a new Service Principal and a Client Secret as described [here](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)

   And specify the following ENV variables:
   ```   
     export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
     export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
     export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
     export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```

   If creating a new Service Principal with the Contributor role is not possible, you can have terraform use the Azure CLI login as described [here](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html), Basically you will have to run the "az loging" command first, and specify the following ENV variables:
   ```   
     export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
     export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```

   If the Azure CLI has no valid session, when running Terraform plan or apply an error similar to this should be received:
   "Error: Error building account: Error getting authenticated object ID: Error parsing json result from the Azure CLI: Error waiting for the Azure CLI: exit status 1"

## Getting Started

There are 3 main subdirectories in this repository: 
- [keys](/keys) - Can be used to store the private & public keys to access via SSH the SDKPerf & Solace Broker Nodes
- [terraform](/terraform) - Contains Terraform configuration & template files to create resources on the cloud as well as files to be used by Ansible (Inventories, Playbooks, Variables)
- [ansible](/ansible) - Contains playbooks, inventories, variables & roles to be used by Ansible to configure the VMs. There are static files that can be modified according to what is needed, as well as files that will get dinamycally created by Terraform upon execution, based on the resources terraform creates (ex: number of nodes, public or private IPs, etc.).

Also, inside of each of those subdirectories, there are README files that can provide extra information as well as describing what CAN or HAS TO be configured on each section.

> :warning: The SSH keys to be used should have restictive permissions (ex: 600), otherwise Terraform and Ansible could trigger an error while connecting to the VMs

## Creating Resources

Once all the variables and configurations have been set according to our needs, we can have Terraform create all the infrastructure for us, by going into the appropiate PATH where the Terraform resource files are located (ex: [/terraform/aws/HA](/terraform/aws/HA) and typing the following commands:

   ```   
     terraform init
     terraform apply
   ```

and typing "yes" when prompted.

## Running SDKPerf Tests

Read the [/ansible/README.md](/ansible/README.md) file

## Destroying the resources

Once the testing has concluded and the cloud resources are no longer needed, we can destroy all of them by simply going into the appropiate PATH where the Terraform resource files are located (ex: [/terraform/aws/HA](/terraform/aws/HA) and running the Terraform command: 

   ```   
     terraform destroy
   ```

and typing "yes" when prompted.

## Authors

See the list of [contributors](https://github.com/solacese/terraform-ansible-solace-sdkperf/graphs/contributors) who participated in this project.

## Resources

**To tie Terraform and Ansible together, we do two things:**

- Run an Ansible playbook after the Virtual Machine has been provisioned using Terraform's "local_exec" provisioner
- Generate inventory files from our VM instances by formatting Terraform's output

Terraform will automatically use the playbooks under [/ansible/playbooks/bootstrap](/ansible/playbooks/bootstrap)  to set up our VM instances.  
Once all the infrastructure has been created & configured, we can use Ansible to manually execute playbooks on [/ansible/playbooks/sdkperf](/ansible/playbooks/sdkperf) to run our SDKPerf tests on the SDKPerf nodes we created with Terraform.


For more information try these resources:

- Introduction to Terraform at: https://www.terraform.io/intro/index.html
- How Ansible Works at: https://www.ansible.com/overview/how-ansible-works
- Ansible Intro to Playbooks at: https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html
- Ansible and HashiCorp (Terraform): Better Togethers at: https://www.hashicorp.com/resources/ansible-terraform-better-together/
- Terraform Azure provider docs at: https://www.terraform.io/docs/providers/azurerm/index.html
- Terraform AWS provider docs at: https://www.terraform.io/docs/providers/aws/index.html
- Install Azure CLI - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
- Amazon EC2 Instance Types at: https://aws.amazon.com/ec2/instance-types/
- Azure VM Sizes at: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
- Azure Managed Disk details at: https://azure.microsoft.com/en-us/pricing/details/managed-disks/
- Get a better understanding of [Solace technology](http://dev.solace.com/tech/).
- Check out the [Solace blog](http://dev.solace.com/blog/) for other interesting discussions around Solace technology
- Ask the [Solace community.](http://dev.solace.com/community/)