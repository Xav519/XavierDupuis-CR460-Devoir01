# Définition du fournisseur Azure
provider "azurerm" {
  features {}
}

# Étape 7: Création du Groupe de Ressources
resource "azurerm_resource_group" "rg" {
  name     = "RG-Devoir-Cloud-XavierDupuis"
  location = "East US"
}

# Étape 8: Création du Réseau Virtuel (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "VNet-Devoir-XavierDupuis"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Étape 8: Création du Sous-réseau (Subnet)
resource "azurerm_subnet" "subnet" {
  name                 = "Subnet-Interne-XavierDupuis"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}