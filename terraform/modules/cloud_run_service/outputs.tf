output "services" {

  value = {
    for k, v in google_cloud_run_v2_service.service :
    k => v.uri
  }

}
