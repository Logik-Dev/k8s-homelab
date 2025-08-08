# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Kubernetes homelab setup using:
- **OpenTofu** for infrastructure as code to provision 3 VMs via libvirt
- **Talos Linux** as the Kubernetes distribution for creating a cluster
- **libvirt** as the virtualization provider

## Architecture

The project follows a layered approach:
1. **Infrastructure Layer**: OpenTofu configurations for VM provisioning
2. **OS Layer**: Talos Linux configuration for bare-metal Kubernetes
3. **Kubernetes Layer**: Cluster configuration and workloads

## Common Commands

### OpenTofu Operations
```bash
# Initialize Terraform/OpenTofu
tofu init

# Plan infrastructure changes
tofu plan

# Apply infrastructure
tofu apply

# Destroy infrastructure
tofu destroy
```

### Talos Operations
```bash
# Generate Talos configuration
talosctl gen config <cluster-name> <cluster-endpoint>

# Apply configuration to nodes
talosctl apply-config --insecure --nodes <node-ip> --file <config-file>

# Bootstrap the cluster
talosctl bootstrap --nodes <control-plane-ip>

# Get kubeconfig
talosctl kubeconfig --nodes <control-plane-ip>
```

### Development Workflow
1. Modify OpenTofu configurations for VM infrastructure
2. Plan and apply infrastructure changes with `tofu plan` and `tofu apply`
3. Configure Talos on provisioned VMs
4. Bootstrap Kubernetes cluster
5. Deploy applications and services

### Cluster Management
```bash
# Destroy the cluster (preserves infrastructure)
tofu destroy --target=module.cluster

# Recreate the cluster with new configuration
tofu apply
```

## Key Configuration Files

- `main.tf` or `*.tf` files: OpenTofu infrastructure definitions
- `talos/` directory: Talos configuration files
- `kubernetes/` directory: Kubernetes manifests and configurations

## Prerequisites

- OpenTofu CLI installed
- talosctl CLI installed
- libvirt/KVM setup on host system
- kubectl for Kubernetes management
