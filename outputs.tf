
output "private_key" {
  value = var.private_key
  sensitive = true
  depends_on = [null_resource.create_instance]
}

output "cert" {
  value = var.cert
  depends_on = [null_resource.create_instance]
}
