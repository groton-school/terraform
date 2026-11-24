
locals {
  source_hashes = {
    for name, source_dir in var.services : name => sha256(join("", [
      for filename in sort(fileset("${var.source_path}/${source_dir}", "**")) :
      "${filename}:${filesha256("${var.source_path}/${source_dir}/${filename}")}"
    ]))
  }

  image_uris = {
    for name, hash in local.source_hashes :
    name => "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/${name}:${hash}"
  }
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = var.retain_versions
    }
  }

  cleanup_policies {
    id     = "delete-older-versions"
    action = "DELETE"

    condition {
      tag_state  = "ANY"
      older_than = "86400s"
    }
  }
}

resource "terraform_data" "build_image" {
  for_each         = var.services
  triggers_replace = [local.source_hashes[each.key]]

  provisioner "local-exec" {
    command = <<-EOT
      gcloud builds submit \
        --project=${var.project_id} \
        --region=${var.region} \
        --config=${path.module}/cloudbuild.yaml \
        --substitutions=_IMAGE=${local.image_uris[each.key]},_CACHE_IMAGE=${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/${each.key}-cache:latest \
        ${var.source_path}/${each.value}
    EOT
  }

  depends_on = [google_artifact_registry_repository.repo]
}
