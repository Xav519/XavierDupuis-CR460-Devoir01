# Définition du fournisseur Azure
provider "azurerm" {
  features {}
}

# Étape 7: Création du Groupe de Ressources
resource "azurerm_resource_group" "rg" {
  name     = "RG-Devoir-Cloud-XavierDupuis"
  location = "East US"
}