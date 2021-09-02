output "namespace" {
  description = "Namespace used for Cert Manager"
  value       = try(kubernetes_namespace.cert-manager.0.metadata.0.name, "")
}
