variable "service_accounts" {
  type = map(object({
    account_id   = string
    display_name = string
    description  = optional(string)
  }))
}
