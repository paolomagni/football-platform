module "storage" {
  source = "../../modules/storage"

  bucket_name       = "football-data-org-raw-dev"
  location          = "US"
  autoclass_enabled = false
  force_destroy     = true
}

module "service_accounts" {
  source = "../../modules/service_account"

  service_accounts = {
    function = {
      account_id   = "football-functions-dev"
      display_name = "Football Functions Dev"
      description  = "Service account for development and testing"
    }
  }
}

module "football_data_api_secret" {
  source = "../../modules/secret_manager"

  secret_id = "football-data-api-key-dev"
}

resource "google_secret_manager_secret_iam_member" "function_secret_access" {
  project   = var.project_id
  secret_id = module.football_data_api_secret.secret_id

  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${module.service_accounts.emails["function"]}"
}