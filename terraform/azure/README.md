# Solace - Terraform & Ansible automated deployment - Azure Deployment

## Instructions

1. **Select the type of deployment you need: standalone or HA**  
   Terraform configuration files for AWS have been separated into 2 folders, according to the infrastructure you need to create:
   - [standalone brokers](./standalone)
   - [HA brokers](./HA)
   Select the one needed by getting into the respective folder.

2. **Edit az-variables**  
   This file contains variables that will allow us to customize the instances that Terraform will provision on Azure.  
   Additional instructions are included in the file.

3. **Edit the /terraform/templates/playbooks/start-sdkperf-xx.tpl files**  
   These files contain the base SDKPerf tests that we'll run Manually via Ansible on our SDKPerf nodes, and will target our Solace Broker nodes.

   You can customize values like:
   - broker_port
   - broker_msg_vpn
   - client_username
   - client_password
   - client_connection_count
   - msg_payload_size_bytes
   - persistent

> :warning: Make sure the changes are aligned with the resources to be created by Terraform as well as the configurations to be applied by Ansible at bootstrap.

4. **Edit the /terraform/templates/playbooks/vars/testvpn-sol-brokers-vars.tpl file**  
   This file contains the Solace configurations to be created on the Solace brokers via SEMP triggered by Ansible at bootstrap.

   You can customize values like:
   - max_spool_usage
   - msg_vpn name
   - Client Profile
   - Client Username
   - Queues

> :information_source: Notice that this file has not been located under /ansible/playbooks/vars/, because although most of its contents are static, there is at the end of the file a dynamic block for Terraform to create a number of Solace queues, based on the number of SDKPerf nodes created.
> :warning: Make sure the changes are aligned with the resources to be created by Terraform as well as the configurations to be applied by Ansible at bootstrap.

5. **Configure Terraform to use the credentials of a sufficiently privileged IAM role**  
   The easiest approach is to create a new Service Principal and a Client Secret as described here https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html

   And specify the following ENV variables:
   ```   
     export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
     export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
     export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
     export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```

   If creating a new Service Principal with the Contributor role is not possible, you can have Terraform use the Azure CLI login as describe here: https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html, Basically you will have to run the "az loging" command first, and specify the following ENV variables:
   ```   
     export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
     export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```

   Before running the "terraform apply" command.

   If the Azure CLI has no valid session, when running Terraform plan or apply an error similar to this should be received:
   "Error: Error building account: Error getting authenticated object ID: Error parsing json result from the Azure CLI: Error waiting for the Azure CLI: exit status 1"