output "database_id" {
  value = google_firestore_database.db.name
}

output "region" {
  value = google_firestore_database.db.location_id
}

