# ==============================================
# VARIABLES
# ==============================================

variable "otc_cloud" {
  description = "Open Telekom Cloud endpoint"
  type        = string
  default     = "https://iam.eu-de.otc.t-systems.com:443/v3"
}

variable "otc_region" {
  description = "Open Telekom Cloud region"
  type        = string
  default     = "eu-de"
}

variable "otc_tenant_id" {
  description = "Open Telekom Cloud tenant ID"
  type        = string
  sensitive   = true
}

variable "otc_access_key" {
  description = "Open Telekom Cloud access key"
  type        = string
  sensitive   = true
}

variable "otc_secret_key" {
  description = "Open Telekom Cloud secret key"
  type        = string
  sensitive   = true
}

variable "otc_domain_name" {
  description = "Open Telekom Cloud domain name"
  type        = string
  default     = "OTC00000000001000000xxx"  # Replace with your domain
}
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-de-01", "eu-de-02", "eu-de-03"]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "node_flavor" {
  description = "Flavor for worker nodes"
  type        = string
  default     = "s3.xlarge.2" # 4 vCPU, 8GB RAM
}

variable "master_flavor" {
  description = "Flavor for master nodes"
  type        = string
  default     = "s3.large.2" # 2 vCPU, 4GB RAM
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "BWI-KVInfoSys"
    Environment = "Production"
    Owner       = "BWI-DevOps-Team"
    ManagedBy   = "Terraform"
  }
}
