variable "state_bukcet_name" {
  type = string
  description = "The name of the S3 bucket to store the Terraform state file"
  default     = " terraform-state-bucket"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy the EKS cluster"
  default     = "us-west-2"
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
  default     = "eks-cluster"
}

variable "node_group_name" {
  type        = string
  description = "The name of the EKS node group"
  default     = "eks-node-group"
}

variable "desired_capacity" {
  type        = number
  description = "The desired number of worker nodes"
  default     = 2
}

variable "max_capacity" {
  type        = number
  description = "The maximum number of worker nodes"
  default     = 3
}

variable "min_capacity" {
  type        = number
  description = "The minimum number of worker nodes"
  default     = 1
}

variable "instance_type" {
  type        = list(string)
  description = "The instance type for the worker nodes"
  default     = ["t3.medium"]
}

// defein desired_size and max_size and min_size in mapping called "autoscale_params"
variable "autscale_params" {
  type = map(number)
  description = "desired_size, max_size, min_size"
  default = {
    desired_size = 2
    max_size = 3
    min_size = 1
  }
}

variale "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10..0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks for the public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks for the private subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "availability_zones" {
  type        = list(string)
  description = "The availability zones for the subnets"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
