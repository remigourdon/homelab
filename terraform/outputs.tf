output "talosconfig" {
  description = "Talos configuration"
  value       = module.cluster.talosconfig
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes configuration"
  value       = module.cluster.kubeconfig
  sensitive   = true
}
