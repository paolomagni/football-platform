terraform {
  backend "gcs" {
    bucket = "footballplatform-tfstate-dev"
    prefix = "terraform/state"
  }
}
