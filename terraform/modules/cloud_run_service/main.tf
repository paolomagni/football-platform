resource "google_cloud_run_v2_service" "service" {

  for_each = var.services

  name     = each.value.name
  location = each.value.location

  template {

    timeout = each.value.timeout

    containers {

      image = each.value.image

      base_image_uri = each.value.function != null ? each.value.function.base_image : null

      resources {
        limits = {
          cpu    = each.value.cpu
          memory = each.value.memory
        }

        cpu_idle          = true
        startup_cpu_boost = true
      }

      dynamic "env" {
        
        for_each = [
          for key in concat(
            ["PROJECT_ID", "BUCKET_NAME"],
            sort([
              for key in keys(each.value.env) :
              key if !contains(["PROJECT_ID", "BUCKET_NAME"], key)
            ])
          ) : {
            name  = key
            value = each.value.env[key]
          }
          if contains(keys(each.value.env), key)
        ]

        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      dynamic "env" {
        for_each = {
          for k in sort(keys(each.value.secret_env)) :
          k => each.value.secret_env[k]
        }

        content {
          name = env.key

          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }
    }

    service_account = each.value.service_account
  }

  dynamic "build_config" {
    for_each = each.value.function != null ? [each.value.function] : []

    content {
      function_target          = build_config.value.function_target
      image_uri                = each.value.image
      base_image               = build_config.value.base_image
      enable_automatic_updates = build_config.value.enable_automatic_updates
      source_location          = build_config.value.source_location
    }
  }

  ingress = each.value.ingress


  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].containers[0].name,
      client
    ]
  }
}
