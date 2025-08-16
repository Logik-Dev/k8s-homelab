output "vm_ids" {
  description = "IDs of created VMs"
  value       = concat(
    [for vm in libvirt_domain.talos_controlplane : vm.id],
    [for vm in libvirt_domain.talos_worker : vm.id]
  )
}

output "vm_names" {
  description = "Names of created VMs" 
  value       = concat(
    [for vm in libvirt_domain.talos_controlplane : vm.name],
    [for vm in libvirt_domain.talos_worker : vm.name]
  )
}

output "schematic_id" {
  description = "Generated Talos Image Factory schematic ID"
  value       = talos_image_factory_schematic.cluster_schematic.id
}
