# ==============================================
# CCE KUBERNETES CLUSTER (Updated for compatibility)
# ==============================================

# CCE Cluster
resource "opentelekomcloud_cce_cluster_v3" "main" {
  name                   = "${var.project_name}-cluster"
  cluster_type           = "VirtualMachine"
  flavor_id              = var.master_flavor
  vpc_id                 = opentelekomcloud_vpc_v1.main.id
  subnet_id              = opentelekomcloud_vpc_subnet_v1.subnets[0].id
  eip                    = opentelekomcloud_vpc_eip_v1.cluster_eip.publicip[0].ip_address
  container_network_type = "overlay_l2"
  container_network_cidr = "172.16.0.0/16"

  # Enable features
  multi_az            = true
  authentication_mode = "rbac"

  # Use labels instead of unsupported tags
  labels = {
    Project     = var.tags["Project"]
    Environment = var.tags["Environment"]
    Owner       = var.tags["Owner"]
    ManagedBy   = var.tags["ManagedBy"]
  }
}

# Node Pool
resource "opentelekomcloud_cce_node_pool_v3" "main" {
  cluster_id         = opentelekomcloud_cce_cluster_v3.main.id
  name               = "${var.project_name}-node-pool"
  os                 = "HCE OS 2.0"
  flavor             = var.node_flavor
  initial_node_count = var.node_count
  availability_zone  = var.availability_zones[0]
  key_pair           = opentelekomcloud_compute_keypair_v2.k8s_keypair.name

  # Scaling configuration
  scale_enable             = true
  min_node_count           = 1
  max_node_count           = 10
  scale_down_cooldown_time = 100
  priority                 = 1

  # Root volume
  root_volume {
    size       = 40
    volumetype = "SSD"
  }

  # Data volume
  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}

# Key Pair for SSH access
resource "opentelekomcloud_compute_keypair_v2" "k8s_keypair" {
  name       = "${var.project_name}-keypair"
  public_key = file("~/.ssh/id_rsa.pub") # Adjust path as needed
}

# Get Kubeconfig

data "opentelekomcloud_cce_cluster_kubeconfig_v3" "kubeconfig" {
  cluster_id = opentelekomcloud_cce_cluster_v3.main.id
}
locals {
  kubeconfig_content = data.opentelekomcloud_cce_cluster_kubeconfig_v3.kubeconfig.kubeconfig
}
resource "local_sensitive_file" "kubeconfig" {
  content  = local.kubeconfig_content
  filename = "kubeconfig.yaml"

  lifecycle {
    ignore_changes = [content]
  }
}

