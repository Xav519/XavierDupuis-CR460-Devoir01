# Définition du fournisseur Azure
provider "azurerm" {
  features {}
}

# Étape 7: Création du Groupe de Ressources
resource "azurerm_resource_group" "rg" {
  name     = "RG-Devoir-Cloud-XavierDupuis"
  location = "canadacentral"
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

# Étape 9: 1. Créer l'interface réseau (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "nic-devoir-XavierDupuis"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Étape 9: 2. Créer la Machine Virtuelle Linux (Ubuntu)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "VM-devoir-XavierDupuis"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

 # Note: En production, je dois utiliser une méthode plus sécurisée pour les mots de passe, ssh keys, ou Azure Key Vault. Ici, c'est juste pour les besoins du devoir.
  admin_password                  = "Password123!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}