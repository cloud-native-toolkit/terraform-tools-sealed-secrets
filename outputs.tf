
output "private_key" {
  value = var.private_key
  sensitive = true
  depends_on = [null_resource.create_instance]
}

output "cert" {
  value = var.cert
  depends_on = [null_resource.create_instance]
}

output "namespace" {
  value = var.namespace
  depends_on = [null_resource.create_namespace]
}
