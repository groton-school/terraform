variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "repository_id" {
  type    = string
  default = "build-artifacts"
}

variable "services" {
  description = "Map of service names to source subdirectories of `source_path`"
  type        = map(string)
}

variable "source_path" {
  description = "Base path to source for all services"
  type        = string
}

variable "retain_versions" {
  description = "Number of recent artifact versions to retain beyond 24 hours"
  type        = number
  default     = 5
}
