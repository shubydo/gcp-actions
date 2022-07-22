variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "The zone to deploy to"
  default     = "us-central1-a"
}

variable "environment" {
  type        = string
  description = "Name of the environment to deploy to"
  default     = "dev"
}
