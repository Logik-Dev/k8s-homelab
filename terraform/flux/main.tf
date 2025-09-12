locals {
  agekey_secret = templatefile(
    "${path.module}/agekey.tftpl",
    {
      agekey = provider::sops::file("${path.module}/secrets.yaml").data.agekey
    }
  )
}
resource "kubectl_manifest" "namespace" {
  depends_on = [var.cilium_deps]
  yaml_body  = file("${path.module}/namespace.yaml")
}

resource "kubectl_manifest" "agekey" {
  depends_on = [kubectl_manifest.namespace]
  yaml_body  = local.agekey_secret
}

resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "clusters/${var.env}"

}
