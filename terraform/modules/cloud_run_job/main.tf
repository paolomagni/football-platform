resource "google_cloud_run_v2_job" "job" {

  for_each = var.jobs

  name     = each.value.name
  location = each.value.location

  template {

    task_count = each.value.task_count

    template {

      max_retries = each.value.max_retries
      timeout     = each.value.timeout

      service_account = each.value.service_account

      containers {

        name  = each.value.container_name
        image = each.value.image

        resources {
          limits = {
            cpu    = each.value.cpu
            memory = each.value.memory
          }
        }

        volume_mounts {
          name       = each.value.volume_name
          mount_path = each.value.secret_mount_path
        }
      }


      volumes {

        name = each.value.volume_name

        secret {

          secret = each.value.secret_name

          items {

            version = "latest"
            path    = each.value.secret_path
          }
        }
      }
    }
  }


  lifecycle {
    ignore_changes = [
      client,
      client_version
    ]
  }
}
