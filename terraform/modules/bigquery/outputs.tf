output "datasets" {

  value = {
    for k, dataset in google_bigquery_dataset.dataset :
    k => dataset.id
  }

}
