resource "google_service_account" "runners" {
  for_each = toset(var.services)

  account_id   = "${each.key}-runner"
  display_name = "Cloud Run runner for ${each.key}"
}

resource "google_project_iam_member" "log_writer" {
  for_each = google_service_account.runners

  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${each.value.email}"
}
