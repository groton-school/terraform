output "service_uris" {
  description = "URIs for the individual services"
  value = {
    app = module.app.uri
  }
}
