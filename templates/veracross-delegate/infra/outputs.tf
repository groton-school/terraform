output "service_uris" {
  description = "URIs for the individual services"
  value = {
    app    = module.app.uri
    tokens = module.tokens.uri

  }
}

output "secret_configuration" {
  description = "Google Cloud Console URL to configure secret values"
  value       = "https://console.cloud.google.com/security/secret-manager/secrets?project=${module.project.project_id}"
}


output "oauth_redirect_uri" {
  description = "OAuth 2.0 redirect_uri values to register with Veracross"
  value = [
    "${module.app.uri}/api/auth/callback/veracross",
    "${module.app.uri}/api/auth/delegate/redirect"
  ]
}

output "authorize_url" {
  description = "URL to authorize delegated service account Data API access"
  value       = "${module.app.uri}/api/auth/delegate/authorize"
}
