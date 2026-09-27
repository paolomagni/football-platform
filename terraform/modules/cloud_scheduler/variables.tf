variable "jobs" {

  type = map(object({

    name        = string
    region      = string
    description = optional(string, "")


    schedule  = string
    time_zone = string


    uri         = string
    http_method = string


    base64_body = optional(string)


    oidc_token = optional(object({

      service_account_email = string
      audience              = string

    }))


    oauth_token = optional(object({

      service_account_email = string
      scope                 = string

    }))


    attempt_deadline = optional(string)


    retry_config = optional(object({

      min_backoff_duration = optional(string)
      max_backoff_duration = optional(string)
      max_retry_duration   = optional(string)
      max_doublings        = optional(number)

    }))

  }))
}
