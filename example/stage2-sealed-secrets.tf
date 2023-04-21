module "sealed_secrets" {
  source = "../"

  cert                = module.cert.cert
  private_key         = module.cert.private_key
  cluster_config_file = module.cluster.config_file_path
  namespace          = module.dev_tools_namespace.name
}

module "verify_sealed_secrets" {
  source = "../test/modules/create-sealed-secret"

  kubeconfig         = module.cluster.config_file_path
  namespace          = module.dev_tools_namespace.name
  sealed_secret_cert = module.sealed_secrets.cert
}
