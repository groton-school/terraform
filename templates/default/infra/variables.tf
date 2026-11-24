variable "project_id" {
  type = string
}

variable "source_path" {
  type    = string
  default = "out"
}

variable "region" {
  type    = string
  default = "us-east4"
}

variable "app_url" {
  type    = string
  default = null
}

variable "debug" {
  type    = string
  default = "false"
}
