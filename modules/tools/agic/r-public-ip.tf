resource "azurerm_public_ip" "ip" {
  count               = var.enable_agic ? 1 : 0
  location            = var.location
  name                = local.ip_name
  allocation_method   = var.ip_allocation_method
  resource_group_name = var.resource_group_name
  sku                 = var.ip_sku

  domain_name_label = lower(replace(local.ip_label, "/[\\W_]/", "-"))

  tags = var.ip_tags
}
