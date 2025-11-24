# Documentation : Systèmes de liaison et parrainage utilisateurs

## 1. Lien d'affiliation (déjà existant)
- Un utilisateur affilié (AFFILIATE) peut être lié à un ou plusieurs clients (CLIENT).
- Les commandes passées par un client lié génèrent des commissions pour l'affilié.
- Liaison via la table `affiliate_client_links` (admin ou via code affilié).
- Suivi des commandes et commissions par affilié.

## 2. Parrainage client → client (nouvelle feature)
- Un client (parrain) peut inviter un autre client (filleul).
- Lors de la première commande du filleul, le parrain reçoit un bonus de points de fidélité (ex : 50 points, une seule fois).
- Implémentation :
  - Nouvelle table `client_referrals` :
    - id, parrain_id, filleul_id, date, reward_given (bool), commande_id (optionnel)
  - À la création d'un compte avec code de parrainage, enregistrer la relation.
  - Lors de la première commande du filleul, vérifier la table, attribuer les points au parrain, marquer `reward_given=true`.

## 3. Liaison client → agent service client (SVA)
- Chaque agent (ADMIN ou CUSTOMER_SERVICE) gère un portefeuille de 200 à 500 clients.
- Objectifs :
  - Suivi personnalisé, relance, assistance, prospection, analyse de performance.
- Implémentation :
  - Nouvelle table `client_managers` :
    - id, agent_id, client_id, date_assigned, active (bool)
  - Dashboard pour chaque agent :
    - Nombre de clients gérés
    - Nombre total de commandes de ses clients
    - Revenus générés
    - Durée moyenne entre commandes
    - Alertes clients inactifs (>7j)
    - Classement des agents par performance

## 4. Autres idées de liaisons

## 5. Étapes d’implémentation
1. Créer les tables nécessaires (`client_referrals`, `client_managers`)
2. Ajouter les endpoints API pour :
   - Enregistrer un parrainage
   - Attribuer un client à un agent
   - Récupérer les stats d’un agent
   - Détecter les clients inactifs
3. Mettre à jour la logique de commande pour gérer les bonus de parrainage
4. Créer les dashboards d’analyse pour les agents
5. Ajouter des tests et la documentation API

## 6. Sécurité & RGPD
- Un client ne peut être parrainé qu’une seule fois
- Un agent ne voit que ses propres clients
- Historique des changements d’agent

---

Pour chaque feature, il faudra :
- Définir les modèles Prisma
- Ajouter les routes et contrôleurs
- Mettre à jour les interfaces front (admin, agent, client)
- Documenter les flux et les règles métier

N’hésite pas à demander un exemple de modèle ou d’endpoint pour démarrer !
