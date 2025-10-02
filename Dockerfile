# Start from official Python base image
FROM python:3.11-slim

# Avoid issues with Python output buffering in logs
ENV PYTHONUNBUFFERED=1

# Install system dependencies required by dbt
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install dbt-core + dbt-bigquery with fixed versions
# (This ensures the container always uses the same versions as your local env)
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir \
       dbt-core==1.10.3 \
       dbt-bigquery==1.9.2

# Set the working directory inside the container
WORKDIR /app

# Copy only dbt project files (avoids unnecessary files like __pycache__)
COPY dbt/ ./

# Ensure .dbt folder exists and copy profiles.yml inside it
RUN mkdir -p /root/.dbt
COPY docker/profiles.yml /root/.dbt/profiles.yml

# Install dbt project dependencies (dbt_utils, codegen, dbt_date, etc.)
RUN dbt deps

# Default command when container starts:
# 1. Clean old artifacts
# 2. Reinstall dependencies (safety in case of updates)
# 3. Compile the project (catch errors early)
# 4. Build all models
CMD bash -c "\
    dbt clean && \
    dbt deps && \
    dbt compile && \
    dbt build \
"
