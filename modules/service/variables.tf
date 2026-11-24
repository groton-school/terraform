variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "image" {
  description = "Source artifact image URI"
  type        = string
}

variable "service_account" {
  description = "Runner service account email"
  type        = string
}

variable "invokers" {
  description = "Map of service names to service account emails that can invoke this service"
  type        = map(string)
  default     = {}
}

variable "public" {
  type    = bool
  default = false
}

variable "env_vars" {
  description = "Map of env variable names to values"
  type        = map(string)
  default     = {}
}

variable "secrets_read_only" {
  description = "Map of names of read-only secrets this service needs to their initial values (will be loaded as env variables of the same name)"
  type        = map(string)
  default     = {}
}

variable "secrets_read_write" {
  description = "Map of names of names of secrets this service will be able to read and update to their initial values (will not be loaded as env variables)"
  type        = map(string)
  default     = {}
}

variable "min_instance_count" {
  type    = number
  default = 0
}

variable "max_instance_count" {
  type    = number
  default = null
}
