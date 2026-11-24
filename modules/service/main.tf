resource "google_secret_manager_secret" "secrets_read_only" {
  for_each = var.secrets_read_only

  secret_id = each.key
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "secrets_read_write" {
  for_each = var.secrets_read_write

  secret_id = each.key
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "init" {
  for_each = merge(
    google_secret_manager_secret.secrets_read_only,
    google_secret_manager_secret.secrets_read_write
  )

  secret = each.value.id
  secret_data = try(
    var.secrets_read_only[each.value.secret_id],
    var.secrets_read_write[each.value.secret_id]
  )

  lifecycle {
    ignore_changes = [secret_data, enabled]
  }
}

resource "google_secret_manager_secret_iam_member" "secret_read_access" {
  for_each = merge(
    google_secret_manager_secret.secrets_read_only,
    google_secret_manager_secret.secrets_read_write
  )

  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account}"
}

resource "google_secret_manager_secret_iam_member" "secret_write_access" {
  for_each = google_secret_manager_secret.secrets_read_write

  project   = var.project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretVersionManager"
  member    = "serviceAccount:${var.service_account}"
}


resource "google_cloud_run_v2_service" "service" {
  name                = var.name
  location            = var.region
  deletion_protection = false

  dynamic "scaling" {
    for_each = var.min_instance_count != null ? [var.min_instance_count] : []

    content {
      min_instance_count = scaling.value
    }
  }

  template {
    service_account = var.service_account

    dynamic "scaling" {
      for_each = var.max_instance_count != null ? [var.max_instance_count] : []

      content {
        max_instance_count = scaling.value
      }
    }

    containers {
      image = var.image
      ports {
        container_port = 8080
      }

      dynamic "env" {
        for_each = var.env_vars

        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = google_secret_manager_secret.secrets_read_only

        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value.secret_id
              version = "latest"
            }
          }
        }
      }
    }
  }

  depends_on = [
    google_secret_manager_secret_version.init,
    google_secret_manager_secret_iam_member.secret_read_access
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.public ? 1 : 0

  location = google_cloud_run_v2_service.service.location
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "invokers" {
  for_each = var.invokers

  location = google_cloud_run_v2_service.service.location
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${each.value}"
}
