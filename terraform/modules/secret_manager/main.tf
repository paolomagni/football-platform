resource "google_secret_manager_secret" "secret" {
  secret_id = var.secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "version" {
  count = var.secret_value != null ? 1 : 0

  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_value
}