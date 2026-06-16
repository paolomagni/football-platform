terraform {
  backend "gcs" {
    bucket = "footballplatform-tfstate-prod"
    prefix = "terraform/state"
  }
}
