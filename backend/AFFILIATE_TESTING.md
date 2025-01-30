# Guide de Test du Système d'Affiliation

Ce guide explique comment tester le système d'affiliation en utilisant les collections Postman fournies.

## Prérequis

1. Installer les dépendances :
```bash
cd backend
npm install
```

2. Configurer les variables d'environnement dans `.env` :
```
DATABASE_URL=your_database_url
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_service_key
```

## Configuration du Test

1. Générer les données de test :
```bash
npx ts-node scripts/setup_affiliate_test_data.ts
```

Ce script crée :
- Les niveaux d'affiliation (Bronze, Argent, Or)
- Un article test et un service test
- Un affilié test avec un code de parrainage
- Un client test utilisant le code de parrainage
- Une commande test qui génère une commission

2. Importer les collections Postman :
- `affiliate_api.postman_collection.json` : API complète d'affiliation
- `affiliate_commission_tests.postman_collection.json` : Tests spécifiques aux commissions
- `alpha_laundry_environments.postman_environment.json` : Variables d'environnement

## Scénarios de Test

### 1. Test des Données Initiales

Utiliser la collection `affiliate_api` :
1. Se connecter en tant qu'affilié (`/auth/login`)
2. Vérifier le profil (`/affiliate/profile`)
3. Vérifier le niveau actuel (`/affiliate/current-level`)
4. Vérifier les filleuls (`/affiliate/referrals`)

### 2. Test des Commissions

Utiliser la collection `affiliate_commission_tests` :
1. Se connecter en tant qu'affilié
2. Vérifier les commissions reçues (`/affiliate/commissions`)
3. Vérifier le solde disponible dans le profil
4. Faire une demande de retrait (`/affiliate/withdrawal`)

### 3. Test de la Gestion Administrative

Utiliser la collection `affiliate_commission_tests` :
1. Se connecter en tant qu'admin
2. Lister les demandes de retrait (`/affiliate/admin/withdrawals`)
3. Approuver ou rejeter une demande

## Données de Test

### Comptes de Test
```
Affilié :
- Email: affiliate.test@alphaomedia.com
- Password: affiliate123

Client :
- Email: client.test@alphaomedia.com
- Password: client123

Admin :
- Email: admin@alphaomedia.com
- Password: admin123
```

### Points à Vérifier

1. Calcul des Commissions :
   - Commission directe : 10-20% de la marge (40% du montant)
   - Commission indirecte : 10% de la commission directe

2. Conditions de Retrait :
   - Montant minimum : 25,000 FCFA
   - Compte affilié actif
   - Solde suffisant

3. Niveaux d'Affiliation :
   - Bronze : 0 FCFA (10%)
   - Argent : 500,000 FCFA (15%)
   - Or : 2,000,000 FCFA (20%)

## Résolution des Problèmes

Si vous rencontrez des erreurs :
1. Vérifier que toutes les tables sont créées (`npx prisma db push`)
2. Vérifier que les procédures stockées sont créées
3. Vérifier les logs dans la console du serveur

## Notes Importantes

- Les commissions sont calculées automatiquement lors de la création d'une commande
- Les niveaux sont mis à jour automatiquement en fonction des gains totaux
- Les retraits doivent être approuvés par un administrateur
- Le système envoie des notifications à chaque étape importante