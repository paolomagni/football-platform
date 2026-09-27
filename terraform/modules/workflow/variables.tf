variable "workflows" {

  type = map(object({

    name            = string
    region          = string
    description     = optional(string, "")
    service_account = string

    source_contents = string

  }))
}
