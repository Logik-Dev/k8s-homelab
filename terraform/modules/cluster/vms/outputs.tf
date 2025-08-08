output "vm_ids" {
  description = "IDs of created VMs"
  value       = libvirt_domain.talos_vm[*].id
}

output "vm_names" {
  description = "Names of created VMs" 
  value       = libvirt_domain.talos_vm[*].name
}

output "vlan100_network_id" {
  description = "ID of VLAN 100 network"
  value       = libvirt_network.vlan100_network.id
}

output "vlan200_network_id" {
  description = "ID of VLAN 200 network"
  value       = libvirt_network.vlan200_network.id
}

output "schematic_id" {
  description = "Generated Talos Image Factory schematic ID"
  value       = talos_image_factory_schematic.cluster_schematic.id
}