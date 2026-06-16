data "archive_file" "function_zip" {
  type        = "zip"

  source_dir  = var.source_dir

  output_path = "/tmp/${var.function_name}.zip"
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "${var.function_name}/${var.function_name}.zip"

  bucket = var.source_bucket

  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions2_function" "function" {
  name     = var.function_name

  location = var.region

  build_config {
    runtime     = var.runtime

    entry_point = var.entry_point

    source {
      storage_source {
        bucket = var.source_bucket

        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    max_instance_count = 1

    available_memory = "512M"

    timeout_seconds = 300

    ingress_settings = "ALLOW_ALL"

    service_account_email = var.service_account_email

    environment_variables = var.environment_variables

    secret_environment_variables {
      key        = "FOOTBALL_DATA_API_KEY"
      project_id = var.project_id
      secret     = "football-data-api-key"
      version    = "latest"
    }
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloudfunctions2_function.function.location

  service = google_cloudfunctions2_function.function.name

  role = "roles/run.invoker"

  member = "allUsers"
}
