module "sealed_secrets" {
  source = "./module"

  cluster_config_file = module.dev_cluster.config_file_path
  namespace           = module.dev_capture_tools_state.namespace
}
