module "sealed_secrets" {
  source = "./module"

  cluster_config_file = module.dev_cluster.config_file_path
  namespace           = module.dev_capture_tools_state.namespace
}

module "verify_sealed_secrets" {
  source = "./module/test/modules/create-sealed-secret"

  kubeconfig         = module.dev_cluster.config_file_path
  namespace          = module.dev_capture_tools_state.namespace
  sealed_secret_cert = module.sealed_secrets.cert
}
