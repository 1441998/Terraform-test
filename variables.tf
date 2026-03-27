variable "resource_group_name" {
  type        = string
  description = "The name of your resource group (e.g., Default)"
  default     = "migration-dev"
}

variable "ssh_key_id" {
  type        = string
  description = "The ID of your SSH Key"
  default     = "r006-fb7d06f3-039f-4753-a34a-0c5870c2e0f5"
}

variable "vpc_name" {
  type        = string
  default     = "dallas-vpc"
}
