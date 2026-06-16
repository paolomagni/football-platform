locals {
  buckets = {
    raw = {
      name          = "football-data-org-raw-dev"
      versioning    = true
      force_destroy = true
    }

    functions = {
      name          = "footballplatform-functions-source-dev"
      versioning    = true
      force_destroy = true
    }
  }
}
