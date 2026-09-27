resource "google_artifact_registry_repository" "repository" {

  for_each = var.repositories

  repository_id = each.value.repository_id
  location      = each.value.location
  format        = each.value.format
  description   = try(each.value.description, null)

  lifecycle {
    ignore_changes = [
      cleanup_policy_dry_run,
      docker_config,
    ]
  }
}
