resource "google_bigquery_dataset" "dataset" {

  for_each = var.datasets

  dataset_id = each.value.dataset_id
  location   = each.value.location

}
