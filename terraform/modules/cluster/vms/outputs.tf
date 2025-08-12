output "vm_ids" {
  description = "IDs of created VMs"
  value       = libvirt_domain.talos_vm[*].id
}

output "vm_names" {
  description = "Names of created VMs" 
  value       = libvirt_domain.talos_vm[*].name
}

output "schematic_id" {
  description = "Generated Talos Image Factory schematic ID"
  value       = talos_image_factory_schematic.cluster_schematic.id
}
