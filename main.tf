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

# Étape 10: Création de l'Adresse IP Publique
resource "azurerm_public_ip" "pip" {
  name                = "pip-devoir-XavierDupuis"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Étape 10: Création du groupe de sécurité réseau (NSG) avec une règle pour autoriser le trafic HTTP
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-devoir-XavierDupuis"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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
    public_ip_address_id          = azurerm_public_ip.pip.id # Étape 10: Associer l'IP publique à la NIC
  }
}

# Étape 10: Liaison du NSG à la carte réseau
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Étape 10: Script de déploiement Docker
locals {
  docker_setup = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              # Déploiement d'un container Nginx de test
              sudo docker run -d -p 80:80 --name web-devoir nginx
              EOF
}

# Étape 9: 2. Créer la Machine Virtuelle Linux (Ubuntu)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "VM-devoir-XavierDupuis"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DC1s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

 # Note: En production, je dois utiliser une méthode plus sécurisée pour les mots de passe, ssh keys, ou Azure Key Vault. Ici, c'est juste pour les besoins du devoir.
  admin_password                  = "Password123!"
  disable_password_authentication = false

  # Envoi du script Docker à la VM
  custom_data = base64encode(local.docker_setup)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}