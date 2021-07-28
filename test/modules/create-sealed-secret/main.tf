
locals {
  tmp_dir = "${path.cwd}/.tmp/sealed-secret-test"
  secret_name = "test-secret"
  secret_value = "test value"
  cert_file = "${local.tmp_dir}/sealed-secret.crt"
  secret_file = "${local.tmp_dir}/sealed-secret.json"
}

resource local_file cert_file {
  filename = local.cert_file

  content = var.sealed_secret_cert
}

resource null_resource create_sealed_secret {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-sealed-secret.sh '${local.secret_name}' '${var.namespace}' '${local.secret_value}' '${local_file.cert_file.filename}' '${local.secret_file}'"
  }
}

resource null_resource apply_sealed_secret {
  depends_on = [null_resource.create_sealed_secret]

  provisioner "local-exec" {
    command = "kubectl apply -n ${var.namespace} -f ${local.secret_file}"

    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }
}

resource null_resource verify_secret {
  depends_on = [null_resource.apply_sealed_secret]

  provisioner "local-exec" {
    command = "kubectl -n ${var.namespace} get secret ${local.secret_name}"

    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }
}
