resource "null_resource" "bootstrap_flux" {
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      
      export KUBECONFIG=${var.kubeconfig_path}
      export GITHUB_TOKEN=$(pass show github/pat)
      
      echo "🔐 Bootstrapping age key for SOPS..."
      ${path.module}/bootstrap-flux-agekey.sh
      
      echo "🚀 Bootstrapping FluxCD..."
      flux bootstrap github \
        --owner=Logik-Dev \
        --repository=k8s-homelab \
        --branch=main \
        --path=clusters/talos \
        --personal
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      set -e
      
      export KUBECONFIG=../kubeconfig
      
      echo "🔄 Uninstalling FluxCD..."
      flux uninstall --silent
    EOT
  }
}