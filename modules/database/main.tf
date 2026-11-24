resource "google_firestore_database" "db" {
  project     = var.project_id
  name        = var.database_id
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
}

resource "google_project_iam_member" "app_firestore" {
  for_each = var.accessors

  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${each.value}"

  condition {
    title       = "${var.database_id}_only"
    description = "Restrict Firestore access to the ${google_firestore_database.db.name} database"
    expression  = "resource.name == \"projects/${var.project_id}/databases/${google_firestore_database.db.name}\""
  }
}

resource "google_firestore_field" "ttl" {
  for_each = var.ttl

  project    = var.project_id
  database   = google_firestore_database.db.name
  collection = each.key
  field      = each.value

  ttl_config {}

  index_config {}
  lifecycle {
    ignore_changes = [index_config]
  }

  skip_wait = true
}
