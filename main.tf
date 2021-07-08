locals {
  provided_private_key = var.private_key_file != "" ? file(var.private_key_file) : var.private_key
  provided_public_key  = var.public_key_file != "" ? file(var.public_key_file) : var.public_key
  keys_provided = local.provided_private_key != "" && local.provided_public_key != ""
  private_key = local.keys_provided ? local.provided_private_key : tls_private_key.generated_key.private_key_pem
  public_key  = local.keys_provided ? local.provided_public_key : tls_private_key.generated_key.public_key_pem
  secret_name = "sealed-secrets-key"
  deployment_name = "sealed-secrets-controller"
}

resource tls_private_key generated_key {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource tls_self_signed_cert cert {
  key_algorithm   = "RSA"
  private_key_pem = local.private_key

  subject {
    common_name  = "localhost"
    organization = "Cloud-Native Toolkit"
  }

  validity_period_hours = 365 * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource null_resource create_subscription {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-subscription.sh ${var.namespace}"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}

resource null_resource wait_for_crd {
  depends_on = [null_resource.create_subscription]

  provisioner "local-exec" {
    command = "${path.module}/scripts/wait-for-crds.sh"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}

resource null_resource create_tls_secret {
  depends_on = [null_resource.wait_for_crd]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-tls-secret.sh ${var.namespace} ${local.secret_name}"

    environment = {
      KUBECONFIG  = var.cluster_config_file
      PRIVATE_KEY = local.private_key
      PUBLIC_KEY  = tls_self_signed_cert.cert.cert_pem
    }
  }
}

# Create instance
resource null_resource create_instance {
  depends_on = [null_resource.wait_for_crd, null_resource.create_tls_secret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-instance.sh ${var.namespace} ${local.secret_name}"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}

resource null_resource wait_for_deployment {
  depends_on = [null_resource.create_instance]

  provisioner "local-exec" {
    command = "${path.module}/scripts/wait-for-deployment.sh ${var.namespace} ${local.deployment_name}"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}
