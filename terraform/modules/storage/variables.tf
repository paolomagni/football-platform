variable "location" {
  type = string
}

variable "buckets" {
  type = map(object({
    name          = string
    versioning    = bool
    force_destroy = bool
  }))
}

variable "function_service_account_email" {
  type = string
}
