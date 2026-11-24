
variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "database_id" {
  type = string
}

variable "accessors" {
  description = "Map of service names to emails of service accounts that can access this database"
  type        = map(string)
}

variable "ttl" {
  description = "Map of collection names to expiration fields"
  type        = map(string)
  default     = {}
}
