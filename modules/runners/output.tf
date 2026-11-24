output "emails" {
  description = "Map of service names to their runner service account emails"
  value = {
    for k, sa in google_service_account.runners : k => sa.email
  }
}
