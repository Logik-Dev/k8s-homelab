resource "null_resource" "install_cilium" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🔄 Uninstalling Cilium before cluster is destroyed..."
      export KUBECONFIG=../kubeconfig
      cilium-cli uninstall --wait || echo "⚠️ Cilium uninstall failed, continuing..."
    EOT
    on_failure = continue
  }

  provisioner "local-exec" {
    when        = create
    command     = <<-EOT
      set -e

      export KUBECONFIG=${var.kubeconfig_path}

      echo "🔍 Waiting for Kubernetes API..."
      for i in {1..60}; do
        if kubectl cluster-info > /dev/null 2>&1; then
          echo "✅ Kubernetes API ready"
          break
        fi
        echo "⏳ Try $i: API not ready, waiting..."
        sleep 5
      done

      echo "🔍 Waiting for Gateway API CRDs..."
      for i in {1..30}; do
        if kubectl get crd gatewayclasses.gateway.networking.k8s.io > /dev/null 2>&1 && \
           kubectl get crd gateways.gateway.networking.k8s.io > /dev/null 2>&1 && \
           kubectl get crd httproutes.gateway.networking.k8s.io > /dev/null 2>&1; then
          echo "✅ Gateway API CRDs are available"
          break
        fi
        echo "⏳ Try $i: Gateway API CRDs not ready, waiting..."
        sleep 10
      done

      echo "🗑️ Uninstalling existing Cilium..."
      cilium-cli uninstall --wait || echo "⚠️ No existing Cilium installation found"

      echo "🚀 Installing Cilium..."
      cilium-cli install --version 1.17.6 --values ${var.cilium_values_path}
    EOT
    working_dir = path.root
  }

  depends_on = [var.kubeconfig_dependency]
}