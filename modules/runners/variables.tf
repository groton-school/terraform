variable "project_id" {
  type = string
}

variable "services" {
  description = "Service names"
  type        = list(string)
}
