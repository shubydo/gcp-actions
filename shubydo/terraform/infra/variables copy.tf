variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
}

variable "zone" {
  type        = string
  description = "The zone to deploy to"
  default     = "us-central1-b"
}

variable "state_bucket_name" {
  type        = string
  description = "The name of the bucket to set up for terraform remote state"
  default     = "shubydo-deployment-bucket"
}
