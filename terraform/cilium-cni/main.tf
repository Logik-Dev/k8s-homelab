resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.18.1"
  namespace  = "kube-system"
  atomic     = true

  values = [file("${path.module}/values.yaml")]

  depends_on = [var.gateway_api_deps]
}
