# Infrastructure Azure Automatisée avec Terraform

### Déploiement d'une Machine Virtuelle avec Docker et Nginx via Infrastructure as Code

Ce projet démontre le déploiement automatisé d'une infrastructure cloud
sur **Microsoft Azure** en utilisant **Terraform** et des pratiques
d'**Infrastructure as Code (IaC)**.

L'objectif est de provisionner une machine virtuelle Ubuntu dans Azure,
configurer automatiquement son environnement à l'aide de **Cloud-init**,
installer **Docker**, puis déployer un **container Nginx** accessible
publiquement.

Ce projet a été réalisé dans le cadre du **Devoir 01 du cours CR460 --
Infrastructure Cloud**.

------------------------------------------------------------------------

# Architecture de l'Infrastructure

L'infrastructure déployée repose sur les composants Azure suivants :

## Composants principaux

| Ressource | Description |
|-----------|-------------|
| Resource Group | Conteneur logique regroupant toutes les ressources Azure du projet |
| Virtual Network (VNet) | Réseau virtuel isolé permettant la communication entre les ressources |
| Subnet | Sous-réseau dédié pour la machine virtuelle |
| Network Security Group (NSG) | Règles de sécurité réseau autorisant le trafic HTTP (port 80) |
| Public IP Address | Adresse IP publique statique permettant d'accéder au serveur |
| Network Interface (NIC) | Interface réseau connectant la VM au réseau Azure |
| Virtual Machine | Instance Ubuntu exécutant Docker et le container Nginx |

## Configuration de la Machine Virtuelle

| Paramètre | Valeur |
|----------|--------|
| Nom | VM-devoir-XavierDupuis |
| Image | Ubuntu Server 22.04 LTS Gen2 |
| Taille | Standard_DC1s_v3 |
| Région | eastus |
| OS | Linux |

La taille **Standard_DC1s_v3** a été sélectionnée pour contourner
certaines restrictions de quota dans la région Azure utilisée.

------------------------------------------------------------------------

# Déploiement Automatisé (Bootstrapping)

Afin d'automatiser entièrement la configuration du serveur dès son
démarrage, le projet utilise **Cloud-init via la propriété `custom_data`
dans Terraform**.

Ce script permet de :

1.  Mettre à jour le système
2.  Installer Docker
3.  Démarrer le service Docker
4.  Télécharger l'image officielle **Nginx**
5.  Lancer un container Nginx exposé sur le port 80

### Exemple du processus exécuté au démarrage

``` bash
apt update -y
apt install -y docker.io
systemctl start docker
systemctl enable docker
docker run -d -p 80:80 nginx
```

Une fois le déploiement terminé, le serveur web devient accessible via
l'adresse IP publique :

    http://<IP-PUBLIQUE>

Le container **Nginx** sert alors la page web par défaut.

------------------------------------------------------------------------

# Déploiement de l'Infrastructure

## Prérequis

Avant de déployer l'infrastructure, assurez-vous d'avoir installé :

-   Terraform
-   Azure CLI
-   Un compte Azure actif

Authentifiez-vous à Azure :

``` bash
az login
```

### Initialisation Terraform

``` bash
terraform init
```

### Plan d'exécution

``` bash
terraform plan
```

### Déploiement

``` bash
terraform apply
```

Confirmez avec :

    yes

Terraform provisionnera automatiquement toutes les ressources Azure
nécessaires.

------------------------------------------------------------------------

# Défis Techniques Rencontrés

Ce projet a permis de résoudre plusieurs problèmes techniques réels
rencontrés lors du déploiement sur Azure.

## Erreur SkuNotAvailable

Initialement, la VM devait utiliser une instance de la série **B
(Burstable)**.\
Cependant, la région **eastus** ne permettait pas l'allocation de cette
SKU pour l'abonnement utilisé.

**Solution :**

Utilisation de la taille :

    Standard_DC1s_v3

qui était disponible dans cette région.

------------------------------------------------------------------------

## Compatibilité Génération 1 vs Génération 2

Une incompatibilité matérielle a été rencontrée lors du déploiement avec
certaines images Linux.

**Solution :**

Utilisation d'une image compatible **Generation 2 (Gen2)** :

    Ubuntu 22.04 LTS Gen2

Cela garantit la compatibilité avec l'infrastructure Azure moderne.

------------------------------------------------------------------------

## Configuration de l'IP Publique

Une erreur est apparue lors du provisionnement de l'adresse IP publique
avec la configuration suivante :

    allocation_method = "Dynamic"

Certaines configurations réseau nécessitent une **IP Standard
statique**.

**Solution :**

Modification vers :

    allocation_method = "Static"
    sku = "Standard"

Cela permet une configuration réseau plus stable et compatible avec les
ressources associées.

------------------------------------------------------------------------

# Destruction de l'Infrastructure

Pour supprimer complètement toutes les ressources créées dans Azure :

``` bash
terraform destroy
```

Confirmez avec :

    yes

Toutes les ressources seront supprimées proprement.

------------------------------------------------------------------------

# Technologies Utilisées

-   Terraform
-   Microsoft Azure
-   Cloud-init
-   Docker
-   Nginx
-   Infrastructure as Code (IaC)

------------------------------------------------------------------------

# Objectifs du Projet

Ce projet démontre :

-   l'utilisation de **Terraform pour l'automatisation du cloud**
-   le **déploiement reproductible d'infrastructure**
-   l'automatisation de la configuration serveur via **Cloud-init**
-   la résolution de **problèmes techniques réels dans Azure**

------------------------------------------------------------------------

# Auteur

**Xavier Dupuis**

Étudiant en cybersécurité\
Polytechnique Montréal
