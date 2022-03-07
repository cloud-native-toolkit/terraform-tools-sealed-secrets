
locals {
  tmp_dir = "${path.cwd}/.tmp/sealed-secret-test"
  secret_name = "test-secret"
  secret_value = "test value"
  cert_file = "${local.tmp_dir}/sealed-secret.crt"
  secret_file = "${local.tmp_dir}/sealed-secret.json"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["oc", "kubectl", "kubeseal"]
}

resource local_file cert_file {
  filename = local.cert_file

  content = var.sealed_secret_cert
}

resource null_resource create_sealed_secret {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-sealed-secret.sh '${local.secret_name}' '${var.namespace}' '${local.secret_value}' '${local_file.cert_file.filename}' '${local.secret_file}'"

    environment = {
      BIN_DIR = module.setup_clis.bin_dir
      KUBECONFIG = var.kubeconfig
    }
  }
}

resource null_resource apply_sealed_secret {
  depends_on = [null_resource.create_sealed_secret]

  provisioner "local-exec" {
    command = "${module.setup_clis.bin_dir}/kubectl apply -n ${var.namespace} -f ${local.secret_file}"

    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }
}

resource null_resource verify_secret {
  depends_on = [null_resource.apply_sealed_secret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/verify-sealed-secret.sh ${local.secret_name} ${var.namespace}"

    environment = {
      BIN_DIR = module.setup_clis.bin_dir
      KUBECONFIG = var.kubeconfig
    }
  }
}
