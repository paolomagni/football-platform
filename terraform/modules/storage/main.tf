resource "google_storage_bucket" "raw" {
  name     = var.bucket_name
  location = var.location

  force_destroy = var.force_destroy

  autoclass {
    enabled = var.autoclass_enabled
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "function_writer" {
  count = var.function_service_account_email != null ? 1 : 0

  bucket = google_storage_bucket.raw.name

  role = "roles/storage.objectCreator"

  member = "serviceAccount:${var.function_service_account_email}"
}
