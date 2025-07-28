# ==============================================
# OUTPUTS (Simplified and compatible)
# ==============================================

output "cluster_id" {
  description = "CCE Cluster ID"
  value       = opentelekomcloud_cce_cluster_v3.main.id
}

output "cluster_name" {
  description = "CCE Cluster Name"
  value       = opentelekomcloud_cce_cluster_v3.main.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = opentelekomcloud_vpc_v1.main.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = opentelekomcloud_vpc_subnet_v1.subnets[*].id
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig"
  value       = "openstack cce cluster kubeconfig --cluster-id ${opentelekomcloud_cce_cluster_v3.main.id}"
}

output "ssh_key_name" {
  description = "SSH Key Pair Name"
  value       = opentelekomcloud_compute_keypair_v2.k8s_keypair.name
}

# Cluster access details (will be available after cluster creation)
output "cluster_status" {
  description = "Cluster status information"
  value       = "Check cluster in OTC console or use: otc cce cluster kubeconfig --cluster-id ${opentelekomcloud_cce_cluster_v3.main.id}"
}

output "next_steps" {
  description = "Next steps for cluster access"
  value = <<-EOT
    1. Export KUBECONFIG: export KUBECONFIG=./kubeconfig
    2. Test access: kubectl get nodes
    3. Deploy application: kubectl apply -f ../k8s/
  EOT
}
