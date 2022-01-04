variable "cert" {
  type        = string
  description = "The public key that will be used to encrypt sealed secrets. If not provided, a new one will be generated"
  default     = ""
}

variable "private_key" {
  type        = string
  description = "The private key that will be used to decrypt sealed secrets. If not provided, a new one will be generated"
  default     = ""
}

variable "cluster_config_file" {
  type        = string
  description = "Cluster config file for Kubernetes cluster."
}

variable "namespace" {
  type        = string
  description = "The namespace where the sealed secret will be deployed"
  default     = "sealed-secrets"
}
