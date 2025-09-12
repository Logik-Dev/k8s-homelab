# Wait for API server
resource "null_resource" "wait_for_apiserver" {
  provisioner "local-exec" {
    command = <<EOT
    for i in $(seq 1 60); do
      if kubectl get --raw /healthz &>/dev/null; then
        echo "API server is ready"
        exit 0
      fi
      echo "Waiting for API server..."
      sleep 5
    done
    echo "API server not ready after timeout" >&2
    exit 1
    EOT
  }

  depends_on = [var.kubeconfig]
}

# Download
data "http" "manifests" {
  for_each = toset(var.manifest_urls)
  url      = each.value
}

# Apply
resource "kubectl_manifest" "this" {
  depends_on = [null_resource.wait_for_apiserver]

  for_each = data.http.manifests

  yaml_body = each.value.response_body
}
