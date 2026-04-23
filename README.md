# ⚽ FootballPlatform

**FootballPlatform** is a cloud-native data platform that ingests, transforms, and analyzes football match data — starting with the UEFA Champions League.

The project follows modern **analytics engineering** and **data platform** best practices on Google Cloud.

---

## 🚀 Overview

The platform runs entirely on **Google Cloud Platform (GCP)** and includes:

- 🌩️ **Cloud Functions** for ingesting and validating football match data from external APIs
- 🧱 **dbt (Data Build Tool)** for transforming raw data into analytics-ready models
- 🧠 **BigQuery** as the central data warehouse
- 🐳 **Docker + Cloud Build** for reproducible dbt builds
- ▶️ **Cloud Run Jobs** to execute dbt in a serverless and scalable way
- 🔄 **GitHub Actions** for CI/CD and automated deployments
- 📊 **Looker Studio** for analytics and reporting

---

## 📂 Repository Structure

```
football-platform/ 
├── Dockerfile 
├── .gitignore
├── .github
│   └── workflows/
│       └── deploy_dbt.yml
├── LICENSE  
├── README.md  
│  
├── cloud_functions/  
│   ├── configs/  
│   ├── fetch-matches-footballdata/  
│   └── load-cl-matches-footballdata/
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
└── workflows/ 
    └── trigger_dbt_build.yml
```
---

## 🔧 Technologies Used

- **Google Cloud Platform**
  - Cloud Functions
  - Cloud Storage
  - BigQuery
  - Artifact Registry
  - Cloud Build
  - Cloud Run Jobs
- **dbt** (v1.10+)
- **Docker**
- **GitHub Actions (OIDC / Workload Identity Federation)**
- **Python** (3.10+)
- **Looker Studio**

---

## 🔄 CI/CD & Deployment Flow

The dbt project is deployed automatically via **GitHub Actions**.

### High-level flow

1. A push to `main` triggers the GitHub Actions workflow
2. A **Docker image** containing the dbt project is built using **Cloud Build**
3. The image is tagged with the Git commit SHA (immutable)
4. The image is pushed to **Artifact Registry**
5. The **Cloud Run Job** is updated to use the new image

This ensures:
- fully reproducible dbt runs
- immutable deployments
- no “latest” or mutable tags in production

---

## 🧪 Development & Deployment

### Running dbt locally

```bash
cd dbt
dbt build
```

### In production

dbt is executed via Cloud Run Jobs, using the Docker image built by the CI/CD pipeline.

---

## 📅 Roadmap

✅ Raw data ingestion from bucket to BigQuery

✅ dbt models for staging and marts

✅ Dockerized dbt builds

✅ CI/CD with GitHub Actions

✅ Cloud Run Jobs for dbt execution

✅ End-to-end orchestration (scheduler / DAG)

⏳ Infrastructure as Code (Terraform)

✅ Automated tests & data quality checks

---

## 📦 Data Source

Match data is sourced from Football-Data.org, a free public API for football data.

⚠️ This project is for educational and personal use only. Please review Football-Data.org terms before using in production.

---

## 📈 Live Dashboard

View the demo dashboard here: Champions League Dashboard [Data Studio](https://lookerstudio.google.com/s/vnXW0_9aQtI)

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙌 Contributing

This is a personal learning project, but feel free to fork or suggest improvements!

---

## 🔗 Connect

Created by Paolo — [connect with me on LinkedIn](https://www.linkedin.com/in/paolo-magni-091731112/).

---
