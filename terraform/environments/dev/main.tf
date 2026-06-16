module "storage" {
  source = "../../modules/storage"

  location = "US"

  buckets = local.buckets

  function_service_account_email = module.football_functions_sa.email
}

module "fetch_matches_function" {
  source = "../../modules/cloud_function"

  function_name = "fetch-matches-footballdata-dev"

  region = var.region

  source_bucket = "footballplatform-functions-source-dev"

  source_dir = "../../cloud_function_source/fetch-matches-footballdata"

  entry_point = "fetch_matches_footballdata"

  service_account_email = module.football_functions_sa.email

  project_id = var.project_id

  environment_variables = {
    BUCKET_NAME = "football-data-org-raw-dev"
  }
}

module "football_functions_sa" {
  source = "../../modules/service_account"

  account_id   = "football-functions-sa"
  display_name = "Football Functions Service Account"
}

module "football_data_api_secret" {
  source = "../../modules/secret_manager"

  secret_id    = "football-data-api-key"
  secret_value = var.football_data_api_key
}

resource "google_secret_manager_secret_iam_member" "function_secret_access" {

  secret_id = module.football_data_api_secret.secret_id

  role = "roles/secretmanager.secretAccessor"

  member = "serviceAccount:${module.football_functions_sa.email}"
}
