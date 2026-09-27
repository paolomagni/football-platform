output "repositories" {
  value = {
    for k, repo in google_artifact_registry_repository.repository :
    k => repo.id
  }
}
