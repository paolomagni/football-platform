variable "datasets" {
  type = map(object({
    dataset_id = string
    location   = string
  }))
}
