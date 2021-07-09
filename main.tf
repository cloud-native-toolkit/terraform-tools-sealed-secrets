locals {
  provided_private_key = var.private_key_file != "" ? file(var.private_key_file) : var.private_key
  provided_public_key  = var.public_key_file != "" ? file(var.public_key_file) : var.public_key
  keys_provided = local.provided_private_key != "" && local.provided_public_key != ""
  private_key = local.keys_provided ? local.provided_private_key : tls_private_key.generated_key.private_key_pem
  public_key  = local.keys_provided ? local.provided_public_key : tls_private_key.generated_key.public_key_pem
  secret_name = "sealed-secrets-key"
  deployment_name = "sealed-secrets"
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

resource null_resource create_namespace {
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.namespace
  }

  provisioner "local-exec" {
    command = "if ! kubectl get namespace '${self.triggers.namespace}' 1> /dev/null 2> /dev/null; then oc new-project '${self.triggers.namespace}'; fi"

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
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-tls-secret.sh ${self.triggers.namespace} ${self.triggers.secret_name}"

    environment = {
      KUBECONFIG  = self.triggers.kubeconfig
      PRIVATE_KEY = local.private_key
      PUBLIC_KEY  = tls_self_signed_cert.cert.cert_pem
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = "${path.module}/scripts/delete-tls-secret.sh ${self.triggers.namespace} ${self.triggers.secret_name}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

# Create instance
resource null_resource create_instance {
  depends_on = [null_resource.create_namespace, null_resource.create_tls_secret]

  triggers = {
    namespace = var.namespace
    secret_name = local.secret_name
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-instance.sh ${self.triggers.namespace} ${self.triggers.secret_name}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = "${path.module}/scripts/delete-instance.sh ${self.triggers.namespace} ${self.triggers.secret_name}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
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
