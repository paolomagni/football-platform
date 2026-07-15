variable "bucket_name" {
  type = string
}

variable "location" {
  type = string
}

variable "autoclass_enabled" {
  type = bool
}

variable "force_destroy" {
  type = bool
}

variable "function_service_account_email" {
  type    = string
  default = null
}
