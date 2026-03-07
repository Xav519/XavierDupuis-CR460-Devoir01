# Optionnel: Afficher l'IP publique à la fin
output "public_ip_address" {
  value = azurerm_public_ip.pip.ip_address
}