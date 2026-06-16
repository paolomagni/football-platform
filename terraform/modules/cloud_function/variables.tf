variable "function_name" {
  type = string
}

variable "region" {
  type = string
}

variable "source_bucket" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "entry_point" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python311"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "service_account_email" {
  type = string
}

variable "project_id" {
  type = string
}

variable "secret_environment_variables" {
  type = list(object({
    key     = string
    secret  = string
    version = string
  }))
  default = []
}
