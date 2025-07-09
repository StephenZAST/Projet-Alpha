# Cahier des Permissions et Restrictions par Rôle Utilisateur

## Hiérarchie des rôles
1. **SUPER_ADMIN** (utilisateur suprême)
2. **ADMIN**
3. **LIVREUR** (DELIVERY)
4. **CLIENT**
5. **AFFILIE** (AFFILIATE)

---

## Tableau récapitulatif des permissions principales

| Action / Rôle         | SUPER_ADMIN | ADMIN      | LIVREUR   | CLIENT    | AFFILIE   |
|-----------------------|-------------|------------|-----------|-----------|-----------|
| Gérer super admin     | Oui         | Non        | Non       | Non       | Non       |
| Gérer admin           | Oui         | Oui        | Non       | Non       | Non       |
| Gérer livreur         | Oui         | Oui        | Non       | Non       | Non       |
| Gérer client          | Oui         | Oui        | Non       | Non       | Non       |
| Gérer affilié         | Oui         | Oui        | Non       | Non       | Non       |
| Modifier rôles        | Oui         | Oui (sauf super admin) | Non | Non | Non |
| Supprimer utilisateurs| Oui         | Oui (sauf super admin) | Non | Non | Non |
| Accès global/paramètres| Oui        | Oui (limité) | Non      | Non       | Non       |

---

## Détail des permissions par rôle

### SUPER_ADMIN
- Peut tout faire (créer, modifier, supprimer n'importe quel utilisateur, y compris d'autres super admins)
- Peut changer le rôle de n'importe qui
- Peut accéder à toutes les données et logs
- Peut configurer les paramètres globaux de l'application

### ADMIN
- Peut gérer tous les utilisateurs SAUF les super admins
- Peut créer/modifier/supprimer des clients, affiliés, livreurs, et autres admins (sauf super admin)
- Ne peut pas modifier ni supprimer un super admin
- Peut changer le rôle d'un client, affilié, livreur, ou admin (sauf super admin)
- Peut gérer les commandes, services, articles, etc.
- Peut voir les statistiques et rapports

### LIVREUR (DELIVERY)
- Peut voir et gérer uniquement ses propres livraisons
- Ne peut pas accéder à la gestion des utilisateurs, ni aux paramètres globaux
- Ne peut pas modifier de rôles

### CLIENT
- Peut voir et gérer uniquement son propre compte et ses commandes
- Ne peut pas accéder à la gestion des utilisateurs, ni aux paramètres globaux
- Ne peut pas modifier de rôles

### AFFILIE (AFFILIATE)
- Peut voir et gérer son propre compte, ses affiliés, ses commissions
- Ne peut pas accéder à la gestion des utilisateurs, ni aux paramètres globaux
- Ne peut pas modifier de rôles

---

## À implémenter en priorité
- Vérifier le rôle de l'utilisateur authentifié avant toute action sensible (modification/suppression/création d'utilisateur, changement de rôle, etc.)
- Empêcher un admin de modifier ou supprimer un super admin
- Empêcher tout utilisateur non admin/super admin d'accéder à la gestion des utilisateurs
- Limiter les actions des livreurs, clients, affiliés à leur propre compte

---

> Ce document sert de référence pour l'implémentation progressive des permissions et restrictions dans l'application Alpha.
