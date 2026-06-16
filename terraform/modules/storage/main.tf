resource "google_storage_bucket" "bucket" {
  for_each = var.buckets

  name     = each.value.name
  location = var.location

  force_destroy = each.value.force_destroy

  versioning {
    enabled = each.value.versioning
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "function_writer" {
  bucket = google_storage_bucket.bucket["raw"].name

  role = "roles/storage.objectCreator"

  member = "serviceAccount:${var.function_service_account_email}"
}
