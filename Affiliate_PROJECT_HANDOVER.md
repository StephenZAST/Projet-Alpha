# 📱 Affiliate App - Handover & Plan d'implémentation

## 🎯 Vue d'ensemble

L'application "Affiliate" permet aux affiliés d'Alpha Laundry de gérer leur profil affilié, suivre leurs parrainages, consulter les commissions, demander des retraits, et accéder à des ressources (niveaux, codes affiliés, historique). Cette doc est un handover et plan d'implémentation pour l'équipe mobile, calqué sur la structure utilisée dans l'application client/delivery.

### 📊 État actuel (estimation)
- Architecture & Fondations : 60%
- UI/UX écrans principaux : 30%
- Services backend (intégration API affiliés) : 70%
- Authentification & gestion token : 90%
- Notifications & préférences : 40%
- Tests & QA : 0%

---

## 🏗️ Architecture proposée

### 📁 Structure des dossiers recommandée (Flutter + GetX)
```
frontend/mobile/affiliate_app/
├── lib/
│   ├── app.dart                    # Configuration GetMaterialApp
│   ├── main.dart                   # Entrée app + initialisations
│   ├── constants.dart              # URL backend, clés, palette
│   ├── bindings/                   # Bindings GetX pour chaque module
│   ├── controllers/                # GetX controllers (auth, profile, commissions)
│   ├── models/                     # DTOs / modèles (AffiliateProfile, Commission, Withdrawal)
│   ├── routes/                     # Routes GetX
│   ├── screens/                    # Écrans (login, dashboard, profile, referrals...)
│   ├── services/                   # ApiService, AffiliateService, NotificationService
│   ├── widgets/                    # Composants réutilisables (cards, lists)
│   └── utils/                      # Helpers (formatters, validators)
├── pubspec.yaml
└── README.md
```

### 🔧 Stack Technique
- Flutter 3.6+ (ou version utilisée dans le monorepo)
- State Management : GetX
- HTTP Client : Dio
- Validation : formz / zod (dart alternative) ou validators personnalisés
- Stockage local : GetStorage (token + preferences)
- Notifications locales : flutter_local_notifications

---

## 🌐 Intégration Backend (endpoints essentiels)

Base URL : configurée dans `constants.dart` (ex: https://api.alpha.local/api)

Endpoints (relatifs à `/api/affiliate`) :
- POST /register-with-code  -- créer un client avec un code affilié (public)
- GET /profile             -- récupérer profil affilié (auth)
- PUT /profile             -- mettre à jour profil affilié (auth)
- GET /commissions         -- lister commissions (auth) (page, limit)
- POST /withdrawal         -- demander retrait (auth) (body { amount })
- GET /referrals           -- lister filleuls directs (auth)
- GET /levels              -- lister niveaux (public)
- GET /current-level       -- récupérer niveau courant (auth)
- POST /generate-code      -- générer un code affilié (auth)

Admin (si géré côté mobile admin) :
- GET /admin/list
- GET /admin/stats
- GET /admin/withdrawals/pending
- PATCH /admin/withdrawals/:withdrawalId/approve
- PATCH /admin/withdrawals/:withdrawalId/reject
- PATCH /admin/affiliates/:affiliateId/status

Notes : Utiliser header `Authorization: Bearer <token>` pour les routes protégées. Le token est obtenu via endpoints d'auth (shared avec client app).

---

## Écrans proposés & Priorité

Prioriser un MVP qui couvre les besoins métiers essentiels (2-3 semaines) :

1) Auth & Onboarding (haute)
   - Écran Login (peut réutiliser login du client)
   - Écran Inscription affilié / lien depuis `register-with-code`

2) Dashboard Affilié (haute)
   - Vue synthétique : solde disponible, gains mensuels, total gagné, boutons rapides (Retrait, Générer code)
   - Carte des actions récentes (transactions récentes)

3) Détails Commissions & Historique (haute)
   - Liste paginée des transactions de commission
   - Détails d'une transaction (commande liée, date, montant)

4) Retraits (haute)
   - Formulaire demande retrait
   - Validation montant minimum (MIN_WITHDRAWAL_AMOUNT)
   - Feedback état (PENDING, APPROVED, REJECTED)

5) Parrainage & Filleuls (moyenne)
   - Liste filleuls directs
   - Statistiques par filleul (inscriptions, achats éventuels)

6) Niveaux & Récompenses (moyenne)
   - Page listant les `levels` et explication des taux

7) Profil & Préférences (moyenne)
   - Modifier téléphone, préférences de notifications

8) Génération / Partage du code affilié (basse)
   - Générer et partager via OS share sheet

9) Notifications (basse)
   - Notifications locales sur statut retrait, nouveau parrain, etc.

---

## Modèles de données (côté client)

AffiliateProfile (extrait) :
```
id: String
userId: String
affiliateCode: String
commissionBalance: double
totalEarned: double
monthlyEarnings: double
isActive: bool
status: String
levelId?: String
totalReferrals: int
user?: { id, email, firstName, lastName }
```

CommissionTransaction :
```
id: String
orderId?: String
amount: double
status: 'PENDING'|'APPROVED'|'REJECTED'
createdAt: DateTime
```

WithdrawalRequest (client -> server) :
```
{ amount: number }
```

---

## Services & Controllers à implémenter

- `services/api_service.dart` : client Dio centralisé (intercepteurs, refresh token, erreurs)
- `services/affiliate_service.dart` : wrapper des endpoints listés (getProfile, getCommissions, requestWithdrawal...)
- `controllers/auth_controller.dart` : reuse du controller auth existant (login/logout)
- `controllers/affiliate_controller.dart` : GetX controllers spécifiques (state, loading, errors)
- `bindings/affiliate_binding.dart` : Bindings pour injections

Patterns recommandés :
- Réutiliser `ApiService` et la logique d'auth/token du client app
- Centraliser la validation et le mapping des réponses
- Gérer proprement la pagination et caching léger (GetStorage) pour dashboard

---

## Validation & Règles Métier importantes

- Min retrait : `MIN_WITHDRAWAL_AMOUNT = 5000` FCFA (vérifier côté UI avant envoi)
- Affiché des statuts lisibles (PENDING => En attente, APPROVED => Approuvé, REJECTED => Rejeté)
- Protéger actions sensibles (demande de retrait) avec confirmation modale
- Gestion d'erreurs réseau : afficher messages clairs et proposer réessayer
- Concurrency : prévenir double-envoi (désactiver bouton pendant requête)

---

## Tests recommandés

- Unitaires : mapping responses -> modèles, logique validation montant retrait
- Intégration : appels réels mockés vers endpoints `/api/affiliate` (happy path + erreurs)
- E2E (optionnel) : flows critiques (login -> dashboard -> demander retrait)

---

## Points d'attention / Risques

- Les règles exactes de calcul de commission et de niveau doivent être validées avec l'équipe backend (taux indirects, profit margin).
- La table `commission_transactions` est partagée avec d'autres usages (commandes + retraits) ; s'assurer du mapping correct côté client.
- Gestion des rôles : si l'app doit permettre accès admin, séparer clairement UX admin/affiliate.

---

## Commandes de développement

Installation et lancement (PowerShell / terminal) :

```powershell
cd frontend/mobile/affiliate_app
flutter pub get
flutter run
```

Pour analyser le code :
```powershell
flutter analyze
```

---

## Variables d'environnement & configuration

- `API_BASE_URL` : pointant vers le backend (défini dans `constants.dart`)
- Timezone : Africa/Dakar (si notifications programmées)
- Clés de stockage : token JWT (GetStorage key `auth_token` ou équivalent)

---

## Prochaines étapes et roadmap court terme

Phase MVP (2 à 3 semaines) :
1. Scaffolding projet + structure dossiers (1 jour)
2. Réutiliser l'auth existante et intégrer login (1 jour)
3. Créer `AffiliateService` + endpoints principaux : profile, commissions, withdrawal (2-3 jours)
4. Écrans Dashboard & Commissions list (3-4 jours)
5. Formulaire Retrait + validations (2 jours)
6. Tests unitaires basiques (1-2 jours)

Phase v1 (améliorations 1-3 semaines) :
- Notifications et partage de code
- Page Niveaux & Statistiques détaillées
- Améliorations UX et tests E2E

---

## Ressources utiles

- Backend API doc (backend/docs/affiliate_api.md)
- Postman / collection (backend/postman/ - vérifier collection affiliés)
- Exemple login & token reuse : `frontend/mobile/client_app` (si présent dans repo)

---

Si tu veux, je peux :
- générer automatiquement le scaffold Flutter (fichiers et bindings) pour démarrer rapidement ;
- créer `AffiliateService` avec toutes les méthodes API listées et des mocks ;
- implémenter l'écran Dashboard et lister les commissions (prototype fonctionnel).

Indique la ou les actions que tu veux que j'implémente en priorité et je m'en occupe.
