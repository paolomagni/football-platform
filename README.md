# ⚽ FootballPlatform

**FootballPlatform** is a cloud-native pipeline that collects, transforms, and analyzes football match data — starting with the UEFA Champions League.

## 🚀 Overview

The project runs on **Google Cloud Platform** and includes:

- 🌩️ **Cloud Functions** to ingest and validate match data from external sources.
- 🧱 **dbt (Data Build Tool)** to transform raw data into clean models.
- 🧠 **BigQuery** as the central data warehouse.
- 📊 **Looker Studio** to visualize curated mart-level statistics.

---

## 📂 Repository Structure
```
football-platform/ 
├── Dockerfile 
├── .gitignore
├── .github  
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
└── dbt/  
    ├── macros/  
    ├── models/  
    ├── dbt_project.yml  
    ├── package-lock.yml  
    └── packages.yml  
```
---

## 🔧 Technologies Used

- **Google Cloud Platform (GCP)**
  - Cloud Functions
  - Cloud Storage
  - BigQuery
- **dbt** (v1.10+)
- **Python** (3.10+)
- **Looker Studio**

---

## 🧪 Development & Deployment

### Running dbt locally

```bash
cd dbt
dbt build
```
---

## 📅 Roadmap

✅ Raw data ingestion from bucket to BigQuery

✅ dbt models for staging and marts

⏳ End-to-end orchestration

⏳ Terraform setup for infrastructure

⏳ Automated testing & CI/CD pipeline

---

## 📦 Data Source

Match data is sourced from Football-Data.org, a free public API for football data.

⚠️ This project is for educational and personal use only. Please review Football-Data.org terms before using in production.

---

## 📈 Live Dashboard

View the demo dashboard here: Champions League Dashboard [Looker Studio](https://lookerstudio.google.com/s/vnXW0_9aQtI)

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
