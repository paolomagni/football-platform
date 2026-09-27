variable "jobs" {

  type = map(object({

    name     = string
    location = string

    image = string

    service_account = string

    container_name = optional(string, "dbt-job")

    cpu    = optional(string, "1000m")
    memory = optional(string, "512Mi")

    timeout     = optional(string, "600s")
    max_retries = optional(number, 3)
    task_count  = optional(number, 1)

    secret_name = string
    secret_path = string

    volume_name = optional(string, "secret-volume")

    secret_mount_path = optional(string, "/secrets")

  }))
}
