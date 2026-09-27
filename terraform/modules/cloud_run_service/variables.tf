variable "services" {

  type = map(object({

    name     = string
    location = string

    image = string


    cpu    = string
    memory = string

    timeout = string


    service_account = string


    ingress = optional(string, "INGRESS_TRAFFIC_ALL")


    env = optional(map(string), {})

    secret_env = optional(map(object({
      secret  = string
      version = string
    })), {})

    function = optional(object({
      function_target        = string
      base_image              = string
      enable_automatic_updates = optional(bool, false)
      source_location          = optional(string)
    }))    
  }))

}
