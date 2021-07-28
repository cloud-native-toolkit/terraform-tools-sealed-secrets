output "public_key" {
  value = local.public_key
  depends_on = [null_resource.wait_for_deployment]
}

output "private_key" {
  value = local.private_key
  sensitive = true
  depends_on = [null_resource.wait_for_deployment]
}

output "cert" {
  value = tls_self_signed_cert.cert.cert_pem
  depends_on = [null_resource.wait_for_deployment]
}
