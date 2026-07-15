resource "google_service_account" "service_account" {
  for_each = var.service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = try(each.value.description, null)
}
