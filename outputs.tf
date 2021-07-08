output "public_key" {
  value = local.private_key
}

output "private_key" {
  value = local.private_key
  sensitive = true
}
