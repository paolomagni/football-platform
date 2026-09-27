# ⚽ FootballPlatform

**FootballPlatform** is a cloud-native football data platform that ingests, transforms, orchestrates, and models football data into analytics-ready datasets.

The project started with UEFA Champions League data and has evolved into a broader football data platform supporting multiple competitions and automated data pipelines.

The platform follows modern **analytics engineering**, **data engineering**, and **Infrastructure as Code** practices on **Google Cloud Platform (GCP)**.

---

## 🚀 Overview

The platform runs on **Google Cloud Platform (GCP)** and includes:

* ☁️ **Cloud Run services** for serverless football data ingestion and loading functions
* 🔐 **Secret Manager** for securely managing external API credentials
* 🧱 **dbt** for transforming raw data into analytics-ready models, with automated testing and modular transformations
* 🧠 **BigQuery** as the central data warehouse
* 🪣 **Cloud Storage** for raw football data
* 🐳 **Docker + Cloud Build** for reproducible dbt builds
* ▶️ **Cloud Run Jobs** for serverless dbt execution
* 🔄 **Workflows + Cloud Scheduler** for pipeline orchestration and scheduled data imports
* 🏗️ **Terraform** for Infrastructure as Code and reproducible GCP infrastructure management
* 🔑 **GitHub Actions + Workload Identity Federation** for CI/CD
* 📊 **Looker Studio** for analytics and reporting

---

## 🏗️ Architecture

At a high level, the platform follows this flow:

```text
Football-Data.org API
        │
        ▼
Cloud Run ingestion functions
        │
        ├── Secret Manager
        │
        ▼
   Cloud Storage
        │
        ▼
     BigQuery
        │
        ▼
       dbt
        │
        ▼
Analytics-ready models
        │
        ▼
   Looker Studio
```

Pipeline orchestration is handled by **Cloud Scheduler** and **Workflows**, while Terraform manages the underlying GCP infrastructure.

The ingestion functions are maintained as source code in the repository and packaged/deployed through Terraform:

```text
functions/
    │
    ▼
Terraform
    │
    ▼
Cloud Storage source archive
    │
    ▼
Cloud Run build
    │
    ▼
Cloud Run function
```

---

## 📂 Repository Structure

```text
football-platform/

├── .github/
│   └── workflows/
│       └── deploy_dbt.yml
│
├── functions/
│   ├── configs/
│   │   └── competitions_configs_footballdata.json
│   │
│   ├── fetch-matches-footballdata/
│   │   ├── main.py
│   │   └── requirements.txt
│   │
│   ├── load-cl-matches-footballdata/
│   │   ├── main.py
│   │   └── requirements.txt
│   │
│   ├── load-ec-matches-footballdata/
│   │   ├── main.py
│   │   └── requirements.txt
│   │
│   └── load-leagues-matches-footballdata/
│       ├── main.py
│       └── requirements.txt
│
├── dbt/
│   ├── macros/
│   ├── models/
│   ├── dbt_project.yml
│   ├── package-lock.yml
│   └── packages.yml
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   ├── modules/
│   │   ├── artifact_registry/
│   │   ├── bigquery/
│   │   ├── cloud_run_job/
│   │   ├── cloud_run_service/
│   │   ├── cloud_scheduler/
│   │   ├── secret_manager/
│   │   ├── service_account/
│   │   ├── storage/
│   │   └── workflow/
│   └── README.md
│
├── workflows/
│   └── trigger_dbt_build.yml
│
├── Dockerfile
├── .dockerignore
├── .gitignore
├── LICENSE
└── README.md
```

The `functions/` directory contains the Python source code for the Cloud Run ingestion functions.

Terraform packages the individual function directories into source archives and manages their deployment through the Cloud Run v2 API.

---

## 🔧 Technologies Used

### Google Cloud Platform

* **Cloud Run**
* **Cloud Run Jobs**
* **Cloud Storage**
* **BigQuery**
* **Artifact Registry**
* **Cloud Build**
* **Cloud Scheduler**
* **Workflows**
* **Secret Manager**
* **IAM / Service Accounts**

### Data & Analytics

* **dbt** (v1.10+)
* **Python**
* **SQL**
* **Looker Studio**

### Infrastructure & CI/CD

* **Terraform**
* **Docker**
* **GitHub Actions**
* **Workload Identity Federation (OIDC)**

---

## 🔄 Data Pipeline

The production pipeline is orchestrated through scheduled serverless components.

### 1. Data ingestion

Cloud Scheduler triggers the football data ingestion functions for configured competitions.

The ingestion service retrieves match data from **Football-Data.org** and stores the raw responses in Cloud Storage.

The Football-Data.org API credential is provided to the ingestion service through **Google Secret Manager**, rather than being stored directly in the application configuration.

### 2. Loading

Dedicated Cloud Run services load the raw football data into the appropriate BigQuery datasets.

### 3. Transformation

A Cloud Run Job executes the dbt project against BigQuery.

dbt transforms the raw data through staging, intermediate, and mart layers.

### 4. Orchestration

Cloud Workflows coordinates dbt execution, while Cloud Scheduler provides scheduled triggers for data ingestion and pipeline execution.

---

## 🔐 Infrastructure as Code

The GCP infrastructure is managed using **Terraform**.

Terraform manages:

* BigQuery datasets
* Cloud Storage
* Artifact Registry repositories
* Cloud Run services
* Cloud Run Functions
* Cloud Run Jobs
* Cloud Scheduler jobs
* Workflows
* Secret Manager resources
* Service accounts
* IAM bindings
* Required GCP APIs

The infrastructure is organized into reusable Terraform modules with separate `dev` and `prod` environments.

The production environment is managed to maintain a zero-drift Terraform state:

```bash
terraform plan
```

should report:

```text
No changes. Your infrastructure matches the configuration.
```

The Cloud Run Function source code is also managed as part of the Terraform deployment flow. Terraform packages the source directories under `functions/`, stores the resulting archives in a dedicated Cloud Storage bucket, and references those archives from the Cloud Run build configuration.

See [`terraform/README.md`](terraform/README.md) for detailed infrastructure documentation.

---

## 🔄 CI/CD & Deployment

The dbt project is deployed through **GitHub Actions**.

### High-level flow

1. A push to `main` triggers the deployment workflow.
2. The dbt project is packaged into a Docker image.
3. Cloud Build builds the image.
4. The image is tagged using the Git commit SHA.
5. The image is pushed to Artifact Registry.
6. The Cloud Run Job is updated to use the new image.
7. The dbt pipeline can then be executed through the production orchestration layer.

Using immutable commit-based image tags provides reproducible dbt deployments and avoids relying on mutable `latest` tags.

GitHub authentication to GCP uses **Workload Identity Federation**, avoiding long-lived service account keys.

---

## 🧪 Development

The repository supports local development of both the dbt project and the Terraform infrastructure.

### Running dbt locally

```bash
cd dbt
dbt build
```

### Terraform

Terraform environments are located under:

```text
terraform/environments/
```

The `dev` environment provides a lightweight GCP environment for infrastructure experiments and development.

The `prod` environment contains the production infrastructure and pipeline components.

Detailed Terraform instructions are available in:

```text
terraform/README.md
```

---

## 🧱 Data Modeling

The dbt project follows a layered analytics engineering architecture:

```text
Sources
   │
   ▼
Staging
   │
   ▼
Intermediate
   │
   ▼
Marts
   │
   ▼
Analytics / BI
```

### Staging

Source data is cleaned, standardized, and prepared for downstream transformations.

### Intermediate

Reusable business logic and transformations are implemented here.

### Marts

Business-facing datasets are optimized for analytical consumption.

The resulting models support analytical use cases including:

* team performance analysis
* player statistics
* match trends
* competition analysis
* historical football data exploration

---

## 📅 Roadmap

### ✅ Completed

* Raw football data ingestion
* Multiple competition support
* Cloud Storage raw data layer
* BigQuery data warehouse
* dbt staging, intermediate, and mart models
* Automated dbt tests
* Dockerized dbt execution
* Artifact Registry
* Cloud Run Job execution
* Cloud Scheduler orchestration
* Cloud Workflows orchestration
* Terraform Infrastructure as Code
* Separate Terraform environments for development and production
* Secret Manager integration for API credentials
* GitHub Actions CI/CD
* Workload Identity Federation for GitHub authentication
* Cloud Run Function source management through Terraform
* End-to-end pipeline validation
* Looker Studio dashboard

### 🚧 Future Improvements

* More advanced pipeline monitoring and alerting
* Additional football competitions and data sources
* Additional analytical models
* More comprehensive data quality monitoring
* AI-powered analytics assistant for natural-language exploration of the football data platform

---

## 📦 Data Source

Match data is sourced from **Football-Data.org**, a free public football data API.

This project is intended for educational and personal use. Please review the Football-Data.org terms of use before using the platform for production or commercial purposes.

---

## 📈 Live Dashboard

View the project dashboard here:

[Football Platform - Competitions Report — Looker Studio](https://lookerstudio.google.com/s/vnXW0_9aQtI)

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙌 Contributing

This is a personal learning project, but feel free to fork the repository or suggest improvements!

---

## 🔗 Connect

Created by Paolo — [connect with me on LinkedIn](https://www.linkedin.com/in/paolo-magni-091731112/).

