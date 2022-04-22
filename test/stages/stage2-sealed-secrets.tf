module "sealed_secrets" {
  source = "./module"

  cert                = module.cert.cert
  private_key         = module.cert.private_key
  cluster_config_file = module.dev_cluster.config_file_path
  #namespace           = module.dev_capture_tools_state.namespace
  namespace          = module.dev_tools_namespace.name
}

module "verify_sealed_secrets" {
  source = "./module/test/modules/create-sealed-secret"

  kubeconfig         = module.dev_cluster.config_file_path
  #namespace          = module.dev_capture_tools_state.namespace
  namespace          = module.dev_tools_namespace.name
  sealed_secret_cert = module.sealed_secrets.cert
}
