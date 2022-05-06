locals {
  secret_name     = "custom-sealed-secret-${random_string.suffix.result}"
  deployment_name = "sealed-secrets"
  created_by      = "kubeseal-${random_string.random.result}"
  tmp_dir         = "${path.cwd}/.tmp/sealed-secrets"
}

resource random_string suffix {
  length  = 6
  special = false
  lower   = true
  upper   = false
  number  = true
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["helm", "oc", "kubectl", "kustomize"]
}

resource random_string random {
  length           = 16
  lower            = true
  number           = true
  upper            = false
  special          = false
}

resource null_resource create_namespace {
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.namespace
    bin_dir = module.setup_clis.bin_dir
    label = local.created_by
  }

  provisioner "local-exec" {
    command = "if ! ${self.triggers.bin_dir}/oc get namespace '${self.triggers.namespace}' 1> /dev/null 2> /dev/null; then ${self.triggers.bin_dir}/oc new-project '${self.triggers.namespace}' && ${self.triggers.bin_dir}/oc label namespace '${self.triggers.namespace}' created-by=${self.triggers.label} || echo 'Already exists'; fi"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = "if [ $(${self.triggers.bin_dir}/oc get namespace -l created-by=${self.triggers.label} | grep -qc ${self.triggers.namespace}) -gt 0 ]; then ${self.triggers.bin_dir}/oc delete project ${self.triggers.namespace}; else echo 'Namespace created by someone else: ${self.triggers.namespace}'; fi"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

resource null_resource create_tls_secret {
  depends_on = [null_resource.create_namespace]

  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.namespace
    secret_name = local.secret_name
    bin_dir = module.setup_clis.bin_dir
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-tls-secret.sh '${self.triggers.namespace}' '${self.triggers.secret_name}' '${local.created_by}'"

    environment = {
      BIN_DIR = self.triggers.bin_dir
      KUBECONFIG  = self.triggers.kubeconfig
      PRIVATE_KEY = var.private_key
      CERT        = var.cert
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = "${path.module}/scripts/delete-tls-secret.sh ${self.triggers.namespace} ${self.triggers.secret_name}"

    environment = {
      BIN_DIR = self.triggers.bin_dir
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

data external check_for_instance {
  program = ["bash", "${path.module}/scripts/check-for-instance.sh"]

  query = {
    kube_config = var.cluster_config_file
    namespace = var.namespace
    bin_dir = module.setup_clis.bin_dir
    created_by = local.created_by
  }
}

# Create instance
resource null_resource create_instance {
  depends_on = [null_resource.create_namespace, null_resource.create_tls_secret]

  triggers = {
    namespace = var.namespace
    kubeconfig = var.cluster_config_file
    bin_dir = module.setup_clis.bin_dir
    tmp_dir = local.tmp_dir
    skip = data.external.check_for_instance.result.exists
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-instance.sh '${self.triggers.namespace}' '${local.created_by}'"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
      BIN_DIR = self.triggers.bin_dir
      TMP_DIR = self.triggers.tmp_dir
      SKIP = self.triggers.skip
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = "${path.module}/scripts/delete-instance.sh '${self.triggers.namespace}'"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
      BIN_DIR = self.triggers.bin_dir
      SKIP = self.triggers.skip
    }
  }
}
