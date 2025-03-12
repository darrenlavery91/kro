terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubectl" {
  load_config_file = true
}

variable "kro_version" {
  description = "Version of the KRO Helm chart"
  type        = string
}

resource "helm_release" "kro" {
  name             = "kro"
  chart            = "oci://ghcr.io/kro-run/kro/kro"  # OCI registry chart URL
  namespace        = "kro"
  create_namespace = true
  version          = var.kro_version
}

# resource "kubectl_manifest" "resourcegraphdefinition" {
#   yaml_body  = file("${path.module}/resourcegraphdefinition.yaml")
#   depends_on = [helm_release.kro]
# }

# resource "kubectl_manifest" "instance" {
#   yaml_body  = file("${path.module}/instance.yaml")
#   depends_on = [helm_release.kro]
# }
