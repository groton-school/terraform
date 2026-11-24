terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.12"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  services = {
    app = "app"
  }
  source_path = "${path.root}/../${var.source_path}"
}


module "project" {
  source = "git::ssh://git@github.com/groton-school/terraform.git//modules/project?ref=v1.1.0"

  project_id = var.project_id
}

module "artifacts" {
  source = "git::ssh://git@github.com/groton-school/terraform.git//modules/artifacts?ref=v1.1.0"

  project_id  = module.project.project_id
  region      = module.database.region
  source_path = local.source_path
  services    = local.services
}

module "runners" {
  source = "git::ssh://git@github.com/groton-school/terraform.git//modules/runners?ref=v1.1.0"

  project_id = module.project.project_id
  services   = keys(local.services)
}

locals {
  service_uris = {
    app = coalesce(
      var.app_url,
      "https://${local.services.app}-${module.project.number}.${module.database.region}.run.app"
    )
  }
}

module "app" {
  source = "git::ssh://git@github.com/groton-school/terraform.git//modules/service?ref=v1.1.0"

  project_id      = module.project.project_id
  region          = module.database.region
  name            = local.services.app
  image           = module.artifacts.uris.app
  service_account = module.runners.emails.app
  env_vars = {
    "DEBUG" = var.debug
  }
  public = true
}
