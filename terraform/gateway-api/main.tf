# Download
data "http" "manifests" {
  for_each = toset(var.manifest_urls)
  url      = each.value
}

# Apply
resource "kubectl_manifest" "this" {
  depends_on = [var.wait_for_apiserver]

  for_each = data.http.manifests

  yaml_body = each.value.response_body
}
