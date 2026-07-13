resource "google_project_service" "services" {
  for_each = toset([
    "storage.googleapis.com",
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

module "storage" {
  source = "../../modules/storage"

  location = "US"

  buckets = {
    raw = {
      name          = "football-data-org-raw"
      versioning    = true
      force_destroy = false
    }
  }

}
