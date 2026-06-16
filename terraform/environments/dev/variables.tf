variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "football_data_api_key" {
  type      = string
  sensitive = true
}
