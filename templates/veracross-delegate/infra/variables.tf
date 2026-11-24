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

variable "database_id" {
  type    = string
  default = "(default)"
}

variable "school_route" {
  type    = string
  default = "groton"
}

variable "app_url" {
  type    = string
  default = null
}

variable "tokens_url" {
  type    = string
  default = null
}

variable "debug" {
  type    = string
  default = "false"
}
