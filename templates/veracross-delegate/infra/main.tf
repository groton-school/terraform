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
    app    = "app"
    tokens = "tokens"
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

module "database" {
  source = "git::ssh://git@github.com/groton-school/terraform.git//modules/database?ref=v1.1.0"

  project_id  = module.project.project_id
  region      = var.region
  database_id = var.database_id
  accessors = {
    app = module.runners.emails.app
  }
  ttl = {
    "sessions"     = "expires"
    "accessTokens" = "expiresAt"
    "idTokens"     = "exp"
  }
}

locals {
  service_uris = {
    app = coalesce(
      var.app_url,
      "https://${local.services.app}-${module.project.number}.${module.database.region}.run.app"
    )
    tokens = coalesce(
      var.tokens_url,
      "https://${local.services.tokens}-${module.project.number}.${module.database.region}.run.app"
    )
  }
}

module "tokens" {
  source = "git::ssh://git@github.com/groton-school/terraform.git//modules/service?ref=v1.1.0"

  project_id      = module.project.project_id
  region          = module.database.region
  name            = "tokens"
  image           = module.artifacts.uris.tokens
  service_account = module.runners.emails.tokens
  secrets_read_only = {
    "VC_SVC_CREDENTIALS" = <<-EOT
      {
        "school_route": "groton",
        "client_id": ""
        "client_secret": ""
        "redirect_uri": "${local.service_uris.app}/api/auth/delegate/redirect"
      }
    EOT
  }
  secrets_read_write = {
    "VC_SVC_TOKEN" = "Will be replaced when app is authorized"
  }
  env_vars = {
    "GOOGLE_CLOUD_PROJECT" = module.project.project_id
    "PUBLIC_URL"           = local.service_uris.tokens
    "DEBUG"                = var.debug
  }
  min_instance_count = 1
  max_instance_count = 1
  invokers           = { app = module.runners.emails.app }
  public             = false
}

module "app" {
  source = "git::ssh://git@github.com/groton-school/terraform.git//modules/service?ref=v1.1.0"

  project_id         = module.project.project_id
  region             = module.database.region
  name               = local.services.app
  image              = module.artifacts.uris.app
  min_instance_count = 1
  service_account    = module.runners.emails.app
  secrets_read_only = {
    "AUTH_SECRET"           = "pnpx auth secret"
    "AUTH_VERACROSS_ID"     = "From Veracross OAuth App"
    "AUTH_VERACROSS_SECRET" = "From Veracross OAuth App"
  }
  env_vars = {
    "DATABASE_ID"          = module.database.database_id
    "VC_SVC_CONSUMER_URL"  = local.service_uris.app
    "VC_SVC_PROVIDER_URL"  = module.tokens.uri
    "VC_SVC_ROUTE"         = "groton"
    "AUTH_TRUST_HOST"      = "true"
    "AUTH_URL"             = local.service_uris.app
    "AUTH_VERACROSS_ROUTE" = "groton"
    "DEBUG"                = var.debug
  }
  public = true
}
