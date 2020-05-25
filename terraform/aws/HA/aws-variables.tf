####################################################################################################
# INSTRUCTIONS:
# (1) Customize these variables to your perference
# (2) Make sure the account you're running terraform with has proper permissions in your AWS env
####################################################################################################

# aws config
variable "aws_region" {
  default = "us-west-2"
}

# sdkperf nodes count
variable "sdkperf_nodes_count" {
    default = "2"
    type        = string
    description = "The number of sdkperf nodes to be created."
}
variable "sdkperf_vm_type" {
  default = "t2.micro"    # (2 CPUs  8G RAM - General Purpose)
}

# Solace Brokers
# HA Clusters count
variable "solace_broker_count" {
    default = "1"
    type        = string
    description = "The number of Solace Broker nodes to be created."
}
variable "sol_messaging_vm_type" {
#  default = "t2.medium"   # (2 CPUs  4G RAM - General Purpose Burstable )
  default = "m5.large"    # (2 CPUs  8G RAM - General Purpose)
#  default = "m5.xlarge"    # (4 CPUs 16G RAM - General Purpose)
}
variable "sol_monitor_vm_type" {
  default = "t2.medium"   # (2 CPUs  4G RAM - General Purpose Burstable )
}

# General Variables
variable "tag_owner" {
  default = "Manuel Moreno"
}
variable "tag_days" {
  default = "1"
}
variable "tag_name_prefix" {
  default = "mmoreno-ha"
}
variable "subnet_primary_id" {
  default = ""
  #default = "subnet-0db7d4f1da1d01bd8"
  type        = string
  description = "The AWS subnet_id to be used for hosting the primary brokers and sdkperf nodes - Leave the value empty for automatically creating one."
}
variable "subnet_backup_id" {
  default = ""
  type        = string
  description = "The AWS subnet_id to be used for hosting the backup brokers - If the subnet_primary_id value is left empty we'll automatically create all the Subnets. Otherwise this value must be specified and consistent"
}
variable "subnet_monitor_id" {
  default = ""
  type        = string
  description = "The AWS subnet_id to be used for hosting the monitor brokers - If the subnet_primary_id value is left empty we'll automatically create all the Subnets. Otherwise this value must be specified and consistent"
}


variable "sdkperf_secgroup_ids" {
  default = [""]
  #default = ["sg-08a5f21a2e6ebf19e"]
  description = "The AWS security_group_ids to be asigned to the sdkperf nodes - Leave the value empty for automatically creating one."
}
variable "solacebroker_secgroup_ids" {
  default = [""]
  #default = ["sg-08a5f21a2e6ebf19e"]
  description = "The AWS security_group_ids to be asigned to the Solace broker nodes - Leave the value empty for automatically creating one."
}


# ssh config
# If the Key Pair is already created on AWS leave an empty public_key_path, otherwise terraform will try to create it and upload the public key
variable "aws_ssh_key_name" {
  default = "mmoreno_sdkperf_tfha_key"
  description = "The Key pair Name to be created on AWS."
}
# If no  Private and Public Keys exist, they can be created with the "ssh-keygen -f ../aws_key" command
variable "public_key_path" {
  default = "../../../keys/aws_key.pub"
  description = "Local path to the public key to be uploaded to AWS"
}
variable "private_key_path" {
  default = "../../../keys/aws_key"
  description = "Local path to the private key used to connect to the Instances (Not to be uploaded to AWS)"
}
variable "ssh_user" {
  default = "centos"
  description = "SSH user to connect to the created instances (defined by the AMI being used)"
}

variable "centOS_ami" {
  type        = map
  default = { # CentOS
    us-east-1 = "ami-02eac2c0129f6376b"
    us-east-2 = "ami-0f2b4fc905b0bd1f1"
    us-west-1 = "ami-074e2d6769f445be5"
    us-west-2 = "ami-01ed306a12b7d1c96"
  }
}

# Solace Broker External Storage Variables
variable "solacebroker_storage_device_name" {
  default = "/dev/sdc"
  description = "device name to assign to the storage device"
}
variable "solacebroker_storage_size" {
  default = 200
  description = "Size of the Storage Device in GB"
}
variable "solacebroker_storage_iops" {
  default = "3000"
  description = "Number of IOPs to allocate to the Storage device - must be a MAX ratio or 1:50 of the Storage Size"
}

