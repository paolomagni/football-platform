# 🏗️ FootballPlatform — Terraform

This directory contains the **Terraform Infrastructure as Code (IaC)** configuration used to manage the Google Cloud infrastructure supporting FootballPlatform.

The Terraform configuration is organized into reusable modules and separate environments for **development** and **production**.

The goal is to manage the platform infrastructure declaratively, reproducibly, and with controlled changes through Terraform.

---

## 📐 Architecture

Terraform manages the main infrastructure components required by the FootballPlatform data platform:

```text
                         ┌─────────────────────┐
                         │   Football-Data.org │
                         │         API         │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │     Cloud Run       │
                         │     Functions       │
                         └──────────┬──────────┘
                                    │
                           ┌────────┴────────┐
                           │                 │
                           ▼                 ▼
                    Secret Manager    Cloud Storage
                                             │
                                             ▼
                                         BigQuery
                                             │
                                             ▼
                                            dbt
                                             │
                                             ▼
                                      Analytics / BI

             Cloud Scheduler ───────► Cloud Run Functions

             Cloud Scheduler ───────► Workflows
                                           │
                                           ▼
                                    Cloud Run Job
                                           │
                                           ▼
                                          dbt
```

Terraform manages the infrastructure and IAM relationships required for these components to work together.

Terraform also manages the source archives used to deploy the Cloud Run Functions:

```text
functions/
    │
    ▼
Terraform archive_file
    │
    ▼
Function source ZIP
    │
    ▼
Cloud Storage source bucket
    │
    ▼
Cloud Run build configuration
    │
    ▼
Cloud Run Function
```

---

## 📂 Repository Structure

```text
terraform/

├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── ...
│   │
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── locals.tf
│       ├── versions.tf
│       └── ...
│
├── modules/
│   ├── artifact_registry/
│   ├── bigquery/
│   ├── cloud_run_job/
│   ├── cloud_run_service/
│   ├── cloud_scheduler/
│   ├── secret_manager/
│   ├── service_account/
│   ├── storage/
│   └── workflow/
│
└── README.md
```

The Cloud Run Function source code itself is maintained separately in the repository root:

```text
functions/

├── configs/
│   └── competitions_configs_footballdata.json
│
├── fetch-matches-footballdata/
│   ├── main.py
│   └── requirements.txt
│
├── load-cl-matches-footballdata/
│   ├── main.py
│   └── requirements.txt
│
├── load-ec-matches-footballdata/
│   ├── main.py
│   └── requirements.txt
│
└── load-leagues-matches-footballdata/
    ├── main.py
    └── requirements.txt
```

### Environments

Each environment has its own Terraform root module and state.

### `dev`

The development environment is intentionally lightweight and is designed for infrastructure experiments and testing.

It currently contains a reduced set of infrastructure resources such as:

* Cloud Storage
* Service Account
* Secret Manager
* Secret Manager IAM access

The development environment does **not** duplicate the complete production pipeline.

### `prod`

The production environment contains the infrastructure required to run the complete FootballPlatform data pipeline.

---

## 🧩 Terraform Modules

The infrastructure is split into reusable modules.

| Module              | Responsibility                             |
| ------------------- | ------------------------------------------ |
| `artifact_registry` | Artifact Registry repositories             |
| `bigquery`          | BigQuery datasets                          |
| `cloud_run_job`     | Cloud Run Jobs                             |
| `cloud_run_service` | Cloud Run services and Cloud Run Functions |
| `cloud_scheduler`   | Scheduled pipeline triggers                |
| `secret_manager`    | Secret Manager resources                   |
| `service_account`   | Service accounts and IAM                   |
| `storage`           | Cloud Storage buckets and IAM              |
| `workflow`          | Google Cloud Workflows                     |

This modular structure keeps environment-specific configuration separate from reusable infrastructure definitions.

---

## ☁️ Production Infrastructure

The production environment manages the main GCP components required by FootballPlatform.

### Cloud Run

Terraform manages the Cloud Run services used by the football data pipeline, including:

* `fetch-matches-footballdata`
* `load-cl-matches-footballdata`
* `load-ec-matches-footballdata`
* `load-leagues-matches-footballdata`

The `cloud_run_service` module supports both standard Cloud Run services and serverless functions deployed through the Cloud Run v2 API.

The production configuration also manages the Cloud Run Job used to execute dbt.

### Function Source Management

The source code for the Cloud Run Functions is maintained under the repository-level `functions/` directory.

Terraform packages each function using the `archive` provider and uploads the resulting ZIP archive to a dedicated Cloud Storage bucket:

```text
footballplatform-functions-source
```

Each source archive is content-addressed using its SHA-256 hash. This allows changes to function source code to produce a new source object and a corresponding Cloud Run build configuration.

The production Terraform configuration therefore manages both:

* the Cloud Run Function runtime configuration
* the function source location used by the Cloud Run build

The generated Terraform working files under `.terraform/` are local build artifacts and are not committed to Git.

### BigQuery

Terraform manages the BigQuery datasets used by the platform, including:

* `football_data`
* `champions_league`
* `champions_league_audit`

### Cloud Storage

The production environment manages the bucket used for raw Football-Data.org responses:

```text
football-data-org-raw
```

It also manages the dedicated function source bucket used to store Terraform-generated Cloud Run Function source archives.

### Artifact Registry

Terraform manages the Artifact Registry repositories used by the platform for container images and Cloud Run source/build artifacts.

### Cloud Scheduler

Terraform manages scheduled jobs for football competition imports and dbt execution.

The scheduler configuration covers competitions including:

* Champions League
* Premier League
* Serie A
* Bundesliga
* Ligue 1
* La Liga
* Eredivisie
* Championship
* Primeira Liga
* Brasileirão

### Workflows

Terraform manages the workflow responsible for triggering the dbt build process.

### Service Accounts

Terraform manages the service accounts required by the platform and their associated IAM permissions.

---

## 🔐 Secrets & IAM

Sensitive API credentials are managed using **Google Secret Manager**.

The Football-Data.org API key is stored in:

```text
football-data-api-key
```

The secret value itself is **not managed through Terraform configuration**.

This is intentional: passing the real secret value through Terraform would cause the credential to be stored in Terraform state.

Instead, Terraform manages:

* the Secret Manager secret resource
* IAM access to the secret
* the Cloud Run configuration referencing the secret

The Cloud Run ingestion service receives the API key through a Secret Manager environment variable reference.

Conceptually:

```text
Secret Manager
      │
      │ secretAccessor
      ▼
Cloud Run service
      │
      ▼
FOOTBALL_DATA_API_KEY
```

The service account running the ingestion service is granted:

```text
roles/secretmanager.secretAccessor
```

on the relevant secret.

---

## 🏗️ Providers

The production environment uses the following Terraform providers:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}
```

The current production environment has been validated with:

```text
Terraform 1.13.1
Google provider 6.50.0
```

The `archive` provider is used to package Cloud Run Function source directories into ZIP archives before uploading them to the function source bucket.

---

## 🚀 Getting Started

Terraform commands should be executed from the environment being managed.

For example:

```bash
cd terraform/environments/prod
```

### Initialize Terraform

```bash
terraform init
```

This initializes the working directory and downloads the required providers and modules.

### Format the configuration

```bash
terraform fmt -recursive
```

### Validate the configuration

```bash
terraform validate
```

### Review changes

```bash
terraform plan
```

Always review the plan before applying infrastructure changes.

### Apply changes

```bash
terraform apply
```

Terraform will ask for confirmation when the plan contains changes.

---

## 🔄 Recommended Workflow

The recommended workflow for infrastructure changes is:

```text
Edit Terraform configuration
          │
          ▼
terraform fmt
          │
          ▼
terraform validate
          │
          ▼
terraform plan
          │
          ▼
Review proposed changes
          │
          ▼
terraform apply
          │
          ▼
terraform plan
          │
          ▼
Confirm no unexpected drift
```

For production changes, the Terraform plan should always be reviewed before applying it.

---

## 📥 Importing Existing Infrastructure

FootballPlatform's Terraform infrastructure was initially created by **importing existing GCP resources into Terraform state** rather than recreating the production platform from scratch.

This approach allowed the existing production infrastructure to be brought under Infrastructure as Code while minimizing service disruption.

The general process was:

```text
Existing GCP resource
        │
        ▼
terraform import
        │
        ▼
Terraform state
        │
        ▼
Terraform configuration
        │
        ▼
terraform plan
        │
        ▼
0 changes
```

The production configuration was iteratively aligned with the existing infrastructure until Terraform reported:

```text
No changes. Your infrastructure matches the configuration.
```

The same principle is used when bringing additional existing resources under Terraform management.

---

## 🧪 Infrastructure Validation

After applying infrastructure changes, the environment should be validated using:

```bash
terraform plan
```

A fully synchronized environment should return:

```text
No changes. Your infrastructure matches the configuration.
```

Production resources should also be validated beyond Terraform state where appropriate.

For example, the Football-Data.org ingestion service can be tested end-to-end:

```text
Cloud Run
    │
    ▼
Secret Manager
    │
    ▼
Football-Data.org API
    │
    ▼
Python ingestion function
    │
    ▼
Cloud Storage
```

A successful test confirms that match data can be retrieved and written to the production raw-data bucket.

---

## 🛡️ Security Considerations

The Terraform configuration follows several security principles:

* API credentials are stored in Secret Manager rather than Terraform configuration.
* Secret values are not passed through Terraform variables.
* Cloud Run accesses secrets through Secret Manager IAM.
* GitHub Actions uses Workload Identity Federation instead of long-lived GCP service account keys.
* Terraform configuration should never contain plaintext credentials.
* Sensitive values should not be committed to Git.
* Production infrastructure changes should always be reviewed through `terraform plan`.

If a credential has been exposed, it should be considered compromised and rotated before publishing the repository publicly.

---

## 🧹 State & Drift Management

Terraform state represents the infrastructure managed by Terraform.

The production environment should remain synchronized with the actual GCP infrastructure.

Before making manual changes in GCP, consider whether the resource is already Terraform-managed.

Unexpected manual changes can introduce infrastructure drift:

```text
Terraform configuration
        │
        ▼
Terraform state
        │
        ▼
Actual GCP infrastructure
```

These should remain aligned.

When Terraform reports:

```text
No changes. Your infrastructure matches the configuration.
```

the managed infrastructure is synchronized with the current Terraform configuration.

---

## 📝 Notes

This Terraform configuration is specific to the FootballPlatform project and its GCP architecture.

The modules are intentionally reusable within the project, while the environment configurations define the actual resources required for development and production.

For an overview of the complete data platform and application architecture, see the main project README:

```text
../README.md
```

---

## 📄 License

This project is licensed under the MIT License.
