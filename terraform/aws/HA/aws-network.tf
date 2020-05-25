####################################################################################################
# NOTE: The following network resources will only get created if:
# The "subnet_id" variable is left "empty"
####################################################################################################

resource "aws_vpc" "sdkperf_vpc" {  
  count = var.subnet_primary_id == "" ? 1 : 0

  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  enable_classiclink = "false"
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-vpc"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_subnet" "sdkperf_primary_subnet" {
  count = var.subnet_primary_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.aws_region}a"

  tags = {
      Name    = "${var.tag_name_prefix}-sdkperf-primary-subnet"
      Owner   = var.tag_owner
      Purpose = "sdkperf benchmarking"
      Days    = var.tag_days
  }
}

resource "aws_subnet" "sdkperf_backup_subnet" {
  count = var.subnet_primary_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.aws_region}b"

  tags = {
      Name    = "${var.tag_name_prefix}-sdkperf-backup-subnet"
      Owner   = var.tag_owner
      Purpose = "sdkperf benchmarking"
      Days    = var.tag_days
  }
}

resource "aws_subnet" "sdkperf_monitor_subnet" {
  count = var.subnet_primary_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.aws_region}c"

  tags = {
      Name    = "${var.tag_name_prefix}-sdkperf-monitor-subnet"
      Owner   = var.tag_owner
      Purpose = "sdkperf benchmarking"
      Days    = var.tag_days
  }
}

resource "aws_internet_gateway" "sdkperf_gw"{
  count = var.subnet_primary_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-gw"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_route_table" "sdkperf_routetable_p"{
  count = var.subnet_primary_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdkperf_gw[0].id
  }
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-routetable-p"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_route_table" "sdkperf_routetable_b"{
  count = var.subnet_primary_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdkperf_gw[0].id
  }
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-routetable-b"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_route_table" "sdkperf_routetable_m"{
  count = var.subnet_primary_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdkperf_gw[0].id
  }
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-routetable-m"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_route_table_association" "sdkperf_RTA_P"{
  count = var.subnet_primary_id == "" ? 1 : 0

  subnet_id = aws_subnet.sdkperf_primary_subnet[0].id
  route_table_id = aws_route_table.sdkperf_routetable_p[0].id
}

resource "aws_route_table_association" "sdkperf_RTA_B"{
  count = var.subnet_primary_id == "" ? 1 : 0

  subnet_id = aws_subnet.sdkperf_backup_subnet[0].id
  route_table_id = aws_route_table.sdkperf_routetable_b[0].id
}

resource "aws_route_table_association" "sdkperf_RTA_M"{
  count = var.subnet_primary_id == "" ? 1 : 0

  subnet_id = aws_subnet.sdkperf_monitor_subnet[0].id
  route_table_id = aws_route_table.sdkperf_routetable_m[0].id
}
