variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
  default     = "us-central1"
}

variable "bucket" {
  type        = string
  description = "The name of the bucket to set up for terraform remote state"
}
