variable "region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource tags"
  type        = string
  default     = "devops-capstone"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-capstone-eks"
}

variable "vpc_cidr" {
  description = "Dedicated project VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones for the lab"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "eks_public_access_cidrs" {
  description = "IPv4 CIDR ranges allowed to access the EKS public API endpoint"
  type        = list(string)
  default     = ["13.232.197.246/32"]
}
