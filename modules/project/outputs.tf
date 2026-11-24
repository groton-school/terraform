output "project_id" {
  value      = data.google_project.project.project_id
  depends_on = [google_project_service.apis]

}

output "number" {
  value      = data.google_project.project.number
  depends_on = [google_project_service.apis]

}
