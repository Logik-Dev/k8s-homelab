data "http" "schematic" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"
  request_body = templatefile("${path.module}/bare-metal.tftpl", {
    extensions = var.extensions
  })
}
