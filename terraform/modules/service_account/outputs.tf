output "emails" {
  value = {
    for k, sa in google_service_account.service_account :
    k => sa.email
  }
}
