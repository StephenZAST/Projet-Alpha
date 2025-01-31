# Database Functions and Procedures Documentation

## Order Management Functions

### 1. create_order_with_items
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Création d'une nouvelle commande avec ses articles |
| **Input Parameters** | - p_userId: UUID<br>- p_serviceId: UUID<br>- p_addressId: UUID<br>- p_items: order_item_input[]<br>- p_isRecurring: boolean<br>- p_recurrenceType: enum |
| **Returns** | Order avec items en JSON |
| **Key Actions** | - Crée la commande<br>- Ajoute les articles<br>- Calcule le total<br>- Gère les prix premium/standard |

### 2. cleanup_old_orders
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Nettoyage et archivage des anciennes commandes |
| **Input Parameters** | - days_threshold: integer |
| **Returns** | Nombre de commandes archivées |
| **Key Actions** | - Archive les commandes livrées anciennes<br>- Met à jour orders_archive<br>- Supprime les anciennes entrées |

## Affiliate System Functions

### 1. process_withdrawal_request
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Traitement des demandes de retrait d'affiliés |
| **Input Parameters** | - p_affiliate_id: UUID<br>- p_amount: decimal |
| **Validations** | - Minimum: 25000 FCFA<br>- Statut affilié actif<br>- Solde suffisant |
| **Key Actions** | - Vérifie l'éligibilité<br>- Crée transaction retrait<br>- Met à jour solde affilié |

### 2. approve_withdrawal
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Approbation d'une demande de retrait |
| **Input Parameters** | - p_withdrawal_id: UUID |
| **Key Actions** | - Vérifie statut demande<br>- Met à jour en "APPROVED"<br>- Enregistre timestamp |

### 3. calculate_available_commission
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Calcul commission disponible |
| **Input Parameters** | - p_affiliate_id: UUID |
| **Returns** | Montant total disponible (decimal) |
| **Key Actions** | - Récupère solde commission<br>- Applique calculs si nécessaire |

## User Management Functions

### 1. initialize_user_loyalty_points
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Initialisation points fidélité nouveaux utilisateurs |
| **Triggered** | After INSERT on users |
| **Key Actions** | - Crée enregistrement points<br>- Initialise compteurs à 0 |

## Maintenance Procedures

### 1. maintain_orders_archive
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Maintenance automatique des archives |
| **Scheduling** | Exécution périodique (30 jours) |
| **Key Actions** | - Nettoie anciennes commandes<br>- Maintient performance BD |

### 2. reset_monthly_earnings
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Réinitialisation gains mensuels affiliés |
| **Scheduling** | Exécution mensuelle |
| **Key Actions** | - Remet à zéro gains mensuels<br>- Uniquement affiliés actifs |

## Code Source des Fonctions
[Note: Le code source complet de chaque fonction est disponible mais masqué pour la clarté.
Utilisez la commande \d+ nom_fonction pour voir le code source complet dans psql]