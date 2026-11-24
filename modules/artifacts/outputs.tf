output "uris" {
  description = "Map of service names to artifact image URIs"
  value       = local.image_uris
  depends_on  = [terraform_data.build_image]
}
