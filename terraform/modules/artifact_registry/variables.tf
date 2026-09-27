variable "repositories" {

  type = map(object({

    repository_id = string
    location      = string
    format        = string
    description   = optional(string)

  }))
}
