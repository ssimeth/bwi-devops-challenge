# ==============================================
# TERRAFORM CONFIGURATION - OPEN TELEKOM CLOUD
# ==============================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.36"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.23"
    # }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.11"
    # }
  }

  # Backend für Remote State (optional)
  # backend "s3" {
  #   bucket = "bwi-terraform-state"
  #   key    = "kv-infosys/terraform.tfstate"
  #   region = "eu-de"
  # }
}

# ==============================================
# PROVIDER CONFIGURATION
# ==============================================

provider "opentelekomcloud" {
  auth_url    = var.otc_cloud
  tenant_id   = var.otc_tenant_id
  access_key  = var.otc_access_key
  secret_key  = var.otc_secret_key
  domain_name = var.otc_domain_name
}

# provider "kubernetes" {
#   host                   = opentelekomcloud_cce_cluster_v3.main.status[0].endpoints[0].external
#   cluster_ca_certificate = base64decode(opentelekomcloud_cce_cluster_v3.main.certificate_clusters[0].certificate_authority_data)
#   client_certificate     = base64decode(opentelekomcloud_cce_cluster_v3.main.certificate_users[0].client_certificate_data)
#   client_key             = base64decode(opentelekomcloud_cce_cluster_v3.main.certificate_users[0].client_key_data)
# }

# provider "helm" {
#   kubernetes {
#     host                   = opentelekomcloud_cce_cluster_v3.main.status[0].endpoints[0].external
#     cluster_ca_certificate = base64decode(opentelekomcloud_cce_cluster_v3.main.certificate_clusters[0].certificate_authority_data)
#     client_certificate     = base64decode(opentelekomcloud_cce_cluster_v3.main.certificate_users[0].client_certificate_data)
#     client_key             = base64decode(opentelekomcloud_cce_cluster_v3.main.certificate_users[0].client_key_data)
#   }
# }
