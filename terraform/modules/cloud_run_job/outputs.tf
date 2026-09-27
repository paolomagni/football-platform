output "jobs" {

  value = {
    for key, job in google_cloud_run_v2_job.job :
    key => {
      name     = job.name
      location = job.location
      id       = job.id
    }
  }
}
