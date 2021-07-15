output "public_key" {
  value = local.public_key
}

output "private_key" {
  value = local.private_key
  sensitive = true
}

output "cert" {
  value = tls_self_signed_cert.cert.cert_pem
}
