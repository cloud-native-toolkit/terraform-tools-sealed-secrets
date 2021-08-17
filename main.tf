locals {
  secret_name = "custom-sealed-secrets"
  deployment_name = "sealed-secrets"
}

resource null_resource create_namespace {
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.namespace
  }

  provisioner "local-exec" {
    command = "if ! oc get namespace '${self.triggers.namespace}' 1> /dev/null 2> /dev/null; then oc new-project '${self.triggers.namespace}' && oc label namespace '${self.triggers.namespace}' created-by=sealed-secret-module || echo 'Already exists'; fi"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = "if [ $(kubectl get namespace -l created-by=sealed-secret-module | grep -qc ${self.triggers.namespace}) -gt 0 ]; then oc delete project ${self.triggers.namespace}; else echo 'Namespace created by someone else: ${self.triggers.namespace}'; fi"
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
      PRIVATE_KEY = var.private_key
      CERT        = var.cert
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
