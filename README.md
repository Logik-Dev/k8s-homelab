# K8s Homelab

Infrastructure as Code setup for a Kubernetes homelab using OpenTofu and Talos Linux.

## Architecture

- **Infrastructure Layer**: OpenTofu for VM provisioning via libvirt
- **OS Layer**: Talos Linux for bare-metal Kubernetes
- **Cluster**: 3 control plane nodes with Cilium CNI

## Prerequisites

- OpenTofu CLI
- talosctl CLI
- libvirt/KVM hypervisor
- kubectl

## Quick Start

1. Initialize infrastructure:
   ```bash
   tofu init
   tofu plan
   tofu apply
   ```

2. Bootstrap cluster:
   ```bash
   talosctl bootstrap --nodes 10.0.100.101
   talosctl kubeconfig --nodes 10.0.100.101
   ```

## Configuration

- **VMs**: 3x control plane nodes (16GB RAM, 2 vCPU each)
- **Network**: VLAN 100 (10.0.100.0/24) for Kubernetes traffic
- **Storage**: Ultra-fast NVMe + local storage pools
- **CNI**: Cilium with Gateway API CRDs

## Management

All operations are declarative through Talos configuration patches in `terraform/talos/patches/`.

Common commands are documented in `CLAUDE.md`.