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

  bucket_name       = "football-data-org-raw"
  location          = "US"
  autoclass_enabled = true
  force_destroy     = false

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

module "secret_manager" {
  source = "../../modules/secret_manager"

  secret_id = "dbt-key"
}

module "football_data_api_secret" {
  source = "../../modules/secret_manager"

  secret_id = "football-data-api-key"
}

resource "google_secret_manager_secret_iam_member" "football_data_api_key_accessor" {
  project   = var.project_id
  secret_id = "football-data-api-key"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:946443695753-compute@developer.gserviceaccount.com"
}

module "artifact_registry" {
  source = "../../modules/artifact_registry"

  repositories = {

    cloud_run_source = {
      repository_id = "cloud-run-source-deploy"
      location      = "us-central1"
      description   = "Cloud Run Source Deployments"
      format        = "DOCKER"
    }

    dbt = {

      repository_id = "dbt-repo"
      location      = "us-central1"
      description   = ""
      format        = "DOCKER"
    }
  }
}

module "bigquery" {
  source = "../../modules/bigquery"

  datasets = {

    football_data = {
      dataset_id = "football_data"
      location   = "US"
    }

    champions_league = {
      dataset_id = "champions_league"
      location   = "US"
    }

    champions_league_audit = {
      dataset_id = "champions_league_dbt_test__audit"
      location   = "US"
    }
  }
}

module "cloud_run_job" {

  source = "../../modules/cloud_run_job"

  jobs = {

    dbt = {

      name     = "dbt-build"
      location = "us-central1"

      image = "us-central1-docker.pkg.dev/nimble-theme-279316/dbt-repo/dbt-job:06f0263"

      service_account = module.service_accounts.emails["dbt"]

      cpu    = "1000m"
      memory = "512Mi"

      timeout     = "600s"
      max_retries = 3
      task_count  = 1

      container_name = "dbt-job-1"

      secret_name = "dbt-key"
      secret_path = "dbt-key.json"

      volume_name       = "dbt-key-lez-teh-vof"
      secret_mount_path = "/secrets"
    }
  }
}

resource "google_storage_bucket" "function_source" {
  name     = "footballplatform-functions-source"
  location = "US"

  force_destroy = true

  uniform_bucket_level_access = true
}

data "archive_file" "fetch_matches" {
  type        = "zip"
  source_dir  = "${path.root}/../../../functions/fetch-matches-footballdata"
  output_path = "${path.root}/.terraform/function-source/fetch-matches-footballdata.zip"
}

data "archive_file" "load_cl" {
  type        = "zip"
  source_dir  = "${path.root}/../../../functions/load-cl-matches-footballdata"
  output_path = "${path.root}/.terraform/function-source/load-cl-matches-footballdata.zip"
}

data "archive_file" "load_ec" {
  type        = "zip"
  source_dir  = "${path.root}/../../../functions/load-ec-matches-footballdata"
  output_path = "${path.root}/.terraform/function-source/load-ec-matches-footballdata.zip"
}

data "archive_file" "load_leagues" {
  type        = "zip"
  source_dir  = "${path.root}/../../../functions/load-leagues-matches-footballdata"
  output_path = "${path.root}/.terraform/function-source/load-leagues-matches-footballdata.zip"
}

resource "google_storage_bucket_object" "fetch_matches_source" {
  name   = "fetch-matches-footballdata-${data.archive_file.fetch_matches.output_sha256}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.fetch_matches.output_path
}

resource "google_storage_bucket_object" "load_cl_source" {
  name   = "load-cl-matches-footballdata-${data.archive_file.load_cl.output_sha256}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.load_cl.output_path
}

resource "google_storage_bucket_object" "load_ec_source" {
  name   = "load-ec-matches-footballdata-${data.archive_file.load_ec.output_sha256}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.load_ec.output_path
}

resource "google_storage_bucket_object" "load_leagues_source" {
  name   = "load-leagues-matches-footballdata-${data.archive_file.load_leagues.output_sha256}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.load_leagues.output_path
}

module "cloud_run_service" {

  source = "../../modules/cloud_run_service"


  services = {


    fetch_matches = {

      name     = "fetch-matches-footballdata"
      location = "us-central1"

      image = "us-central1-docker.pkg.dev/nimble-theme-279316/cloud-run-source-deploy/fetch-matches-footballdata"

      cpu    = "1000m"
      memory = "512Mi"

      timeout = "300s"


      service_account = "946443695753-compute@developer.gserviceaccount.com"


      env = {
        BUCKET_NAME = "football-data-org-raw"
      }

      secret_env = {
        FOOTBALL_DATA_API_KEY = {
          secret  = "football-data-api-key"
          version = "2"
        }
      }

      function = {
        function_target          = "fetch_matches_footballdata"
        base_image               = "us-central1-docker.pkg.dev/serverless-runtimes/google-22/runtimes/python312"
        enable_automatic_updates = false
        source_location          = "gs://${google_storage_bucket.function_source.name}/${google_storage_bucket_object.fetch_matches_source.name}"
      }
    }


    load_cl = {

      name     = "load-cl-matches-footballdata"
      location = "us-central1"

      image = "us-central1-docker.pkg.dev/nimble-theme-279316/cloud-run-source-deploy/load-cl-matches-footballdata"


      cpu    = "1000m"
      memory = "512Mi"

      timeout = "300s"


      service_account = "946443695753-compute@developer.gserviceaccount.com"


      env = {
        PROJECT_ID  = var.project_id
        BUCKET_NAME = "football-data-org-raw"
      }

      function = {
        function_target          = "load_cl_matches_footballdata"
        base_image               = "us-central1-docker.pkg.dev/serverless-runtimes/google-22/runtimes/python312"
        enable_automatic_updates = true
        source_location          = "gs://${google_storage_bucket.function_source.name}/${google_storage_bucket_object.load_cl_source.name}"
      }
    }


    load_ec = {

      name     = "load-ec-matches-footballdata"
      location = "us-central1"

      image = "us-central1-docker.pkg.dev/nimble-theme-279316/cloud-run-source-deploy/load-ec-matches-footballdata"


      cpu    = "1000m"
      memory = "512Mi"

      timeout = "300s"


      service_account = "946443695753-compute@developer.gserviceaccount.com"


      env = {
        PROJECT_ID  = var.project_id
        BUCKET_NAME = "football-data-org-raw"
      }

      function = {
        function_target          = "load_ec_matches_footballdata"
        base_image               = "us-central1-docker.pkg.dev/serverless-runtimes/google-22/runtimes/python312"
        enable_automatic_updates = true
        source_location          = "gs://${google_storage_bucket.function_source.name}/${google_storage_bucket_object.load_ec_source.name}"
      }
    }


    load_leagues = {

      name     = "load-leagues-matches-footballdata"
      location = "us-central1"

      image = "us-central1-docker.pkg.dev/nimble-theme-279316/cloud-run-source-deploy/load-leagues-matches-footballdata"


      cpu    = "1000m"
      memory = "512Mi"

      timeout = "300s"


      service_account = "946443695753-compute@developer.gserviceaccount.com"


      env = {
        PROJECT_ID  = var.project_id
        BUCKET_NAME = "football-data-org-raw"
      }

      function = {
        function_target          = "load_leagues_matches_footballdata"
        base_image               = "us-central1-docker.pkg.dev/serverless-runtimes/google-22/runtimes/python312"
        enable_automatic_updates = true
        source_location          = "gs://${google_storage_bucket.function_source.name}/${google_storage_bucket_object.load_leagues_source.name}"
      }
    }
  }
}

module "cloud_scheduler" {

  source = "../../modules/cloud_scheduler"


  jobs = merge(

    {

      for key, job in local.football_competitions_scheduler :

      key => {

        name   = job.name
        region = "us-central1"

        schedule  = job.schedule
        time_zone = "Etc/UTC"


        uri = "https://fetch-matches-footballdata-946443695753.us-central1.run.app/"

        http_method = "POST"


        base64_body = job.base64_body


        oidc_token = {

          service_account_email = module.service_accounts.emails["dbt"]

          audience = "https://fetch-matches-footballdata-946443695753.us-central1.run.app"

        }


        oauth_token = null


        attempt_deadline = "180s"


        retry_config = {

          min_backoff_duration = "5s"
          max_backoff_duration = "3600s"
          max_retry_duration   = "0s"
          max_doublings        = 5

        }

      }

    },


    {


      trigger_dbt_build = {

        name = "trigger-dbt-build"

        region = "us-central1"

        schedule = "0 6 * * 4"

        time_zone = "Etc/UTC"


        uri = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/us-central1/workflows/trigger-dbt-build/executions"


        http_method = "POST"


        base64_body = "e30="


        oidc_token = null


        oauth_token = {

          service_account_email = module.service_accounts.emails["dbt"]

          scope = "https://www.googleapis.com/auth/cloud-platform"

        }


        attempt_deadline = "180s"


        retry_config = {

          min_backoff_duration = "5s"
          max_backoff_duration = "3600s"
          max_retry_duration   = "0s"
          max_doublings        = 5

        }
      }
    }
  )
}

module "workflow" {

  source = "../../modules/workflow"

  workflows = {

    trigger_dbt_build = {

      name   = "trigger-dbt-build"
      region = "us-central1"

      description = ""

      service_account = module.service_accounts.emails["dbt"]

      source_contents = <<-EOF
main:
  steps:
  - execute_dbt_job:
      call: googleapis.run.v2.projects.locations.jobs.run
      args:
        name: projects/nimble-theme-279316/locations/us-central1/jobs/dbt-build
      result: runResult
  - returnOutput:
      return: $${runResult}
EOF

    }
  }
}
