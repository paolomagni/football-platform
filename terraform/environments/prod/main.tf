resource "google_project_service" "services" {
  for_each = toset([
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

  bucket_name   = "football-data-org-raw"
  location      = "US"
  autoclass_enabled = true
  force_destroy = false

  # function_service_account_email = module.service_accounts.function_email
}

module "service_accounts" {
  source = "../../modules/service_account"

  service_accounts = {

    dbt = {
      account_id   = "dbt-runner"
      display_name = "dbt-runner"
      description  = "Service account running dbt build"
    }

    github = {
      account_id   = "github-dbt"
      display_name = "github-dbt"
      description  = "Service account for GitHub Actions: build & deploy dbt"
    }
  }
}
