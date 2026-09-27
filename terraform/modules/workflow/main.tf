resource "google_workflows_workflow" "workflow" {

  for_each = var.workflows

  name            = each.value.name
  region          = each.value.region
  description     = each.value.description
  service_account = each.value.service_account

  source_contents = each.value.source_contents
}
