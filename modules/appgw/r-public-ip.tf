resource "azurerm_public_ip" "ip" {
  location            = var.location
  name                = var.ip_name
  allocation_method   = var.ip_allocation_method
  resource_group_name = var.rg_name
  sku                 = var.ip_sku

  domain_name_label = replace(var.ip_label, "/[\\W_]/", "-")

  tags = var.ip_tags
}