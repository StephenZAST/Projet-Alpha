# Spécifications - Alpha Laundry API

## 1. Rôles Utilisateurs
### Super Admin
- Contrôle total du système
- Gestion des autres admins
- Configuration des commissions et récompenses
- Gestion des services et articles

### Admin
- Gestion des commandes
- Gestion des affiliés
- Validation des retraits
- Création de commandes pour clients

### Affilié
- Génération de code affilié
- Parrainage de clients
- Parrainage d'autres affiliés
- Suivi des commissions
- Demande de retrait

### Client
- Gestion du profil
- Création de commandes
- Parrainage d'autres clients
- Gestion des points de fidélité

### Livreur
- Vue des commandes à collecter/livrer
- Mise à jour des statuts
- Navigation GPS

## 2. Système d'Affiliation
### Fonctionnalités Affilié
- Inscription comme affilié
- Génération code unique
- Dashboard des gains
- Historique des parrainages
- Gestion des sous-affiliés
- Demande de retrait

### Programme Fidélité Client
- Points par parrainage
- Points par commande
- Conversion en réduction
- Historique des points
- Catalogue de récompenses

## 3. Gestion des Commandes
### Types
- Standard (complète)
- Express
- Partielle (minimum requis)
- Récurrente

### Options Récurrence
- Une seule fois
- Hebdomadaire
- Bi-mensuelle
- Mensuelle

### Statuts
- En attente
- Collectée
- En traitement
- Prête
- En livraison
- Livrée

## 4. Articles et Services
### Catégories Articles
- Vêtements
- Linge de maison
- Accessoires
- Chaussures

### Services Par Article
- Standards (lavage, repassage)
- Spéciaux (teinture, détachage)
- Prix variables selon article

## 5. Système de Localisation
- Adresses GPS clients
- Carte interactive livreurs
- Suivi en temps réel
- Optimisation des routes

## 6. Données à Tracker
- Commandes
- Commissions
- Points fidélité
- Performance livreurs
- Statistiques par zone

## 7. Règles Métier
- Commission affiliés : % du montant commande
- Commission sous-affiliés : % réduit
- Points fidélité : 1 point par 1000 FCFA
- Validation retrait : admin requis
- Commande minimum : selon service