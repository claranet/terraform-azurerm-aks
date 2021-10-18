output "namespace" {
  description = "Namespace used for Cert Manager"
  value       = try(kubernetes_namespace.cert_manager[0].metadata[0].name, "")
}
