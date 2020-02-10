resource "kubernetes_cluster_role" "containerlogs" {
  metadata {
    name = "containerhealth-log-reader"
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "containerlogs" {
  metadata {
    name = "containerhealth-read-logs-global"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.containerlogs.metadata.0.name
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "clusterUser"
  }
}

#
# Service accounts
#

resource "kubernetes_service_account" "sa" {
  count = length(var.service_accounts)
  metadata {
    name      = var.service_accounts[count.index].name
    namespace = var.service_accounts[count.index].namespace
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "sa" {
  count = length(var.service_accounts)
  metadata {
    name = var.service_accounts[count.index].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.service_accounts[count.index].role
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.service_accounts[count.index].name
    namespace = var.service_accounts[count.index].namespace
  }
}

data "kubernetes_secret" "sa" {
  count = length(var.service_accounts)

  metadata {
    name      = kubernetes_service_account.sa[count.index].default_secret_name
    namespace = var.service_accounts[count.index].namespace
  }
}