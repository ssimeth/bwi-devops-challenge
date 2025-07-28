# ==============================================
# NETWORK INFRASTRUCTURE (Updated for compatibility)
# ==============================================

# VPC
resource "opentelekomcloud_vpc_v1" "main" {
  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  # Use tags where supported
  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.tags["Project"]
    Environment = var.tags["Environment"]
    Owner       = var.tags["Owner"]
    ManagedBy   = var.tags["ManagedBy"]
  }
}

# Subnets
resource "opentelekomcloud_vpc_subnet_v1" "subnets" {
  count = length(var.subnet_cidrs)

  name              = "${var.project_name}-subnet-${count.index + 1}"
  vpc_id            = opentelekomcloud_vpc_v1.main.id
  cidr              = var.subnet_cidrs[count.index]
  gateway_ip        = cidrhost(var.subnet_cidrs[count.index], 1)
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  # Use tags where supported
  tags = {
    Name        = "${var.project_name}-subnet-${count.index + 1}"
    Project     = var.tags["Project"]
    Environment = var.tags["Environment"]
    Owner       = var.tags["Owner"]
    ManagedBy   = var.tags["ManagedBy"]
  }
}

# Security Groups
resource "opentelekomcloud_networking_secgroup_v2" "k8s_master" {
  name        = "${var.project_name}-k8s-master"
  description = "Security group for Kubernetes master nodes"
}

resource "opentelekomcloud_networking_secgroup_v2" "k8s_worker" {
  name        = "${var.project_name}-k8s-worker"
  description = "Security group for Kubernetes worker nodes"
}

# Security Group Rules - Master
resource "opentelekomcloud_networking_secgroup_rule_v2" "k8s_master_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s_master.id
}

# Security Group Rules - Worker Nodes
resource "opentelekomcloud_networking_secgroup_rule_v2" "k8s_worker_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s_worker.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "k8s_worker_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s_worker.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "k8s_worker_nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = var.vpc_cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s_worker.id
}

# Allow internal communication
resource "opentelekomcloud_networking_secgroup_rule_v2" "internal_communication" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = var.vpc_cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s_worker.id
}

# EIP 
resource "opentelekomcloud_vpc_eip_v1" "cluster_eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.project_name}-cluster-bandwidth"
    size        = 10
    share_type  = "PER"
    charge_mode = "traffic"
  }
  
  tags = {
    Name        = "${var.project_name}-cluster-eip"
    Project     = var.tags["Project"]
    Environment = var.tags["Environment"]
    Owner       = var.tags["Owner"]
    ManagedBy   = var.tags["ManagedBy"]
  }
}