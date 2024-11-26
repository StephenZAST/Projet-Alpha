# Documentation API Alpha Laundry Management System

Cette documentation détaille tous les endpoints API REST disponibles dans le système, organisés par type d'utilisateur et contexte.

## Table des Matières

1. [Authentication](#authentication)
2. [Master Super Admin API](#master-super-admin-api)
3. [Super Admin API](#super-admin-api)
4. [Admin API](#admin-api)
5. [Affiliate API](#affiliate-api)
6. [Customer API](#customer-api)
7. [Structure du Backend](#structure-du-backend)
8. [Opérations Firebase](#opérations-firebase)

## Guide d'Utilisation Rapide

### Base URL
```
https://api.alpha-laundry.com/v1
```

### Authentication
Tous les endpoints (sauf login) nécessitent un token JWT dans le header :
```
Authorization: Bearer <votre_token_jwt>
```

### Format des Réponses
Toutes les réponses suivent ce format :
```json
{
    "success": boolean,
    "message": string,
    "data": any
}
```

## Authentication

### Login
```http
POST /auth/login
```

**Body:**
```json
{
    "email": "string",
    "password": "string"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "token": "string",
        "user": {
            "id": "string",
            "email": "string",
            "role": "string",
            "permissions": ["string"]
        }
    }
}
```

## Master Super Admin API

### Gestion des Administrateurs

#### Lister tous les administrateurs
```http
GET /admin/list
```

#### Créer un administrateur
```http
POST /admin/create
```

**Body:**
```json
{
    "email": "string",
    "password": "string",
    "role": "string",
    "permissions": ["string"]
}
```

#### Modifier un administrateur
```http
PUT /admin/:id
```

#### Supprimer un administrateur
```http
DELETE /admin/:id
```

### Gestion des Affiliés

#### Lister tous les affiliés
```http
GET /affiliate/list
```

#### Créer un affilié
```http
POST /affiliate/create
```

**Body:**
```json
{
    "name": "string",
    "email": "string",
    "address": {
        "street": "string",
        "city": "string",
        "country": "string"
    },
    "contact": {
        "phone": "string",
        "email": "string"
    }
}
```

## Super Admin API

### Gestion des Commandes

#### Lister les commandes
```http
GET /orders
```

Paramètres de requête :
- `status`: Filtrer par statut
- `date`: Filtrer par date
- `page`: Numéro de page
- `limit`: Nombre d'éléments par page

#### Créer une commande
```http
POST /orders
```

**Body:**
```json
{
    "customerId": "string",
    "items": [
        {
            "serviceId": "string",
            "quantity": number
        }
    ],
    "pickupDate": "string",
    "deliveryDate": "string"
}
```

### Gestion des Services

#### Lister les services
```http
GET /services
```

#### Ajouter un service
```http
POST /services
```

## Admin API

### Gestion des Clients

#### Lister les clients
```http
GET /customers
```

#### Ajouter un client
```http
POST /customers
```

## Affiliate API

### Gestion des Ressources

#### Voir les ressources disponibles
```http
GET /resources
```

#### Mettre à jour une ressource
```http
PUT /resources/:id
```

### Gestion des Services

#### Voir les services disponibles
```http
GET /services
```

#### Mettre à jour un service
```http
PUT /services/:id
```

## Customer API

### Commandes

#### Voir mes commandes
```http
GET /orders/my
```

#### Créer une nouvelle commande
```http
POST /orders
```

## Gestion des Erreurs

### Codes d'erreur HTTP

- 400: Bad Request - La requête est mal formée
- 401: Unauthorized - Authentication requise
- 403: Forbidden - Permissions insuffisantes
- 404: Not Found - Ressource non trouvée
- 500: Internal Server Error - Erreur serveur

### Format des erreurs
```json
{
    "success": false,
    "message": "Description de l'erreur",
    "error": {
        "code": "ERROR_CODE",
        "details": {}
    }
}
```

## Bonnes Pratiques

1. **Rate Limiting**
- Maximum 100 requêtes par minute par IP
- Maximum 1000 requêtes par heure par token

2. **Caching**
- Les réponses incluent des headers de cache appropriés
- Utilisez les ETags pour optimiser les requêtes

3. **Sécurité**
- Toutes les requêtes doivent être en HTTPS
- Les tokens JWT expirent après 24 heures
- Utilisation de CORS pour la sécurité

## Webhooks

### Événements disponibles

1. **Commande**
- `order.created`
- `order.updated`
- `order.completed`

2. **Client**
- `customer.created`
- `customer.updated`

### Format des webhooks
```json
{
    "event": "string",
    "timestamp": "string",
    "data": {}
}
```

## Structure du Backend

### Hiérarchie des Fichiers

```
backend/
├── src/
│   ├── controllers/           # Gestionnaires de requêtes HTTP
│   │   ├── admin/
│   │   │   ├── masterSuperAdmin.controller.ts
│   │   │   ├── superAdmin.controller.ts
│   │   │   └── admin.controller.ts
│   │   ├── affiliate/
│   │   │   └── affiliate.controller.ts
│   │   ├── auth.controller.ts
│   │   ├── customer.controller.ts
│   │   └── order.controller.ts
│   │
│   ├── routes/               # Définitions des routes API
│   │   ├── admin/
│   │   │   ├── masterSuperAdmin.routes.ts
│   │   │   ├── superAdmin.routes.ts
│   │   │   └── admin.routes.ts
│   │   ├── affiliate/
│   │   │   └── affiliate.routes.ts
│   │   ├── auth.routes.ts
│   │   ├── customer.routes.ts
│   │   └── order.routes.ts
│   │
│   ├── services/            # Logique métier
│   │   ├── admin/
│   │   │   ├── masterSuperAdmin.service.ts
│   │   │   ├── superAdmin.service.ts
│   │   │   └── admin.service.ts
│   │   ├── affiliate/
│   │   │   └── affiliate.service.ts
│   │   ├── auth.service.ts
│   │   ├── customer.service.ts
│   │   └── order.service.ts
│   │
│   ├── models/             # Modèles de données
│   │   ├── Admin.ts
│   │   ├── Affiliate.ts
│   │   ├── Customer.ts
│   │   ├── Order.ts
│   │   └── Service.ts
│   │
│   ├── middleware/         # Middleware d'authentification et validation
│   │   ├── auth.middleware.ts
│   │   ├── validation.middleware.ts
│   │   └── permissions.middleware.ts
│   │
│   ├── validation/        # Schémas de validation
│   │   ├── admin.validation.ts
│   │   ├── affiliate.validation.ts
│   │   ├── customer.validation.ts
│   │   └── order.validation.ts
│   │
│   ├── utils/            # Utilitaires
│   │   ├── jwt.util.ts
│   │   ├── password.util.ts
│   │   └── response.util.ts
│   │
│   ├── config/          # Configuration
│   │   ├── database.config.ts
│   │   └── app.config.ts
│   │
│   └── app.ts          # Point d'entrée de l'application
│
├── .env               # Variables d'environnement
├── package.json      # Dépendances et scripts
└── tsconfig.json    # Configuration TypeScript
```

### Description des Composants Clés

#### 1. Controllers
Les contrôleurs gèrent les requêtes HTTP et délèguent le traitement aux services appropriés.

Exemple (`admin.controller.ts`):
```typescript
// src/controllers/admin/admin.controller.ts
export class AdminController {
    async createAdmin(req: Request, res: Response) {
        try {
            const admin = await adminService.create(req.body);
            return res.status(201).json({
                success: true,
                data: admin
            });
        } catch (error) {
            return res.status(400).json({
                success: false,
                message: error.message
            });
        }
    }
}
```

#### 2. Routes
Les routes définissent les endpoints API et les relient aux contrôleurs.

Exemple (`admin.routes.ts`):
```typescript
// src/routes/admin/admin.routes.ts
router.post('/admin', 
    authMiddleware, 
    permissionsMiddleware(['CREATE_ADMIN']),
    adminController.createAdmin
);
```

#### 3. Services
Les services contiennent la logique métier principale.

Exemple (`admin.service.ts`):
```typescript
// src/services/admin/admin.service.ts
export class AdminService {
    async create(adminData: IAdminCreate) {
        const hashedPassword = await passwordUtil.hash(adminData.password);
        const admin = new Admin({
            ...adminData,
            password: hashedPassword
        });
        return await admin.save();
    }
}
```

#### 4. Models
Les modèles définissent la structure des données.

Exemple (`Admin.ts`):
```typescript
// src/models/Admin.ts
export interface IAdmin {
    email: string;
    password: string;
    role: string;
    permissions: string[];
}

const AdminSchema = new Schema<IAdmin>({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, required: true },
    permissions: [{ type: String }]
});
```

#### 5. Middleware
Les middleware gèrent l'authentification, la validation et les permissions.

Exemple (`auth.middleware.ts`):
```typescript
// src/middleware/auth.middleware.ts
export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) {
            throw new Error('No token provided');
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        res.status(401).json({
            success: false,
            message: 'Authentication failed'
        });
    }
};
```

### Flux de Données

1. La requête arrive sur une route
2. Passe par les middleware (auth, validation)
3. Est traitée par le contrôleur
4. Le contrôleur appelle le service approprié
5. Le service interagit avec les modèles
6. La réponse remonte la chaîne

## Opérations Firebase

### Configuration Firebase

```typescript
import * as admin from 'firebase-admin';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';

const serviceAccount = require('../../serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

export const db = getFirestore();
export const auth = getAuth();
```

### Collections de Référence

```typescript
// Collections references
export const usersRef = db.collection('users');
export const ordersRef = db.collection('orders');
export const articlesRef = db.collection('articles');
export const subscriptionsRef = db.collection('subscriptionPlans');
```

### Opérations CRUD pour les Équipes

#### 1. Créer une Équipe

```typescript
async function createTeam(teamData: TeamInterface) {
  try {
    const teamRef = await db.collection('teams').add({
      ...teamData,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    return {
      id: teamRef.id,
      ...teamData
    };
  } catch (error) {
    throw new AppError(500, 'Erreur lors de la création de l\'équipe', 'TEAM_CREATE_ERROR');
  }
}
```

#### 2. Récupérer une Équipe

```typescript
async function getTeam(teamId: string) {
  try {
    const teamDoc = await db.collection('teams').doc(teamId).get();
    
    if (!teamDoc.exists) {
      throw new AppError(404, 'Équipe non trouvée', 'TEAM_NOT_FOUND');
    }
    
    return {
      id: teamDoc.id,
      ...teamDoc.data()
    };
  } catch (error) {
    throw new AppError(500, 'Erreur lors de la récupération de l\'équipe', 'TEAM_FETCH_ERROR');
  }
}
```

#### 3. Mettre à Jour une Équipe

```typescript
async function updateTeam(teamId: string, updateData: Partial<TeamInterface>) {
  try {
    const teamRef = db.collection('teams').doc(teamId);
    
    await teamRef.update({
      ...updateData,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    const updatedTeam = await teamRef.get();
    return {
      id: updatedTeam.id,
      ...updatedTeam.data()
    };
  } catch (error) {
    throw new AppError(500, 'Erreur lors de la mise à jour de l\'équipe', 'TEAM_UPDATE_ERROR');
  }
}
```

#### 4. Supprimer une Équipe

```typescript
async function deleteTeam(teamId: string) {
  try {
    await db.collection('teams').doc(teamId).delete();
    return true;
  } catch (error) {
    throw new AppError(500, 'Erreur lors de la suppression de l\'équipe', 'TEAM_DELETE_ERROR');
  }
}
```

#### 5. Lister les Équipes avec Filtres

```typescript
async function listTeams(filters: TeamFilters) {
  try {
    let query = db.collection('teams');
    
    // Appliquer les filtres
    if (filters.type) {
      query = query.where('type', '==', filters.type);
    }
    
    if (filters.status) {
      query = query.where('status', '==', filters.status);
    }
    
    // Pagination
    if (filters.limit) {
      query = query.limit(filters.limit);
    }
    
    if (filters.startAfter) {
      const startAfterDoc = await db.collection('teams').doc(filters.startAfter).get();
      query = query.startAfter(startAfterDoc);
    }
    
    const snapshot = await query.get();
    
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    throw new AppError(500, 'Erreur lors de la récupération des équipes', 'TEAMS_FETCH_ERROR');
  }
}
```

### Gestion des Transactions

```typescript
async function assignMemberToTeam(teamId: string, userId: string) {
  try {
    await db.runTransaction(async (transaction) => {
      const teamRef = db.collection('teams').doc(teamId);
      const userRef = db.collection('users').doc(userId);
      
      const teamDoc = await transaction.get(teamRef);
      const userDoc = await transaction.get(userRef);
      
      if (!teamDoc.exists) {
        throw new AppError(404, 'Équipe non trouvée', 'TEAM_NOT_FOUND');
      }
      
      if (!userDoc.exists) {
        throw new AppError(404, 'Utilisateur non trouvé', 'USER_NOT_FOUND');
      }
      
      transaction.update(teamRef, {
        members: admin.firestore.FieldValue.arrayUnion(userId),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      transaction.update(userRef, {
        teamId: teamId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });
    
    return true;
  } catch (error) {
    throw new AppError(500, 'Erreur lors de l\'assignation du membre à l\'équipe', 'TEAM_ASSIGN_ERROR');
  }
}
```

### Écoute des Changements en Temps Réel

```typescript
function subscribeToTeamChanges(teamId: string, callback: (team: TeamInterface) => void) {
  return db.collection('teams').doc(teamId)
    .onSnapshot((doc) => {
      if (doc.exists) {
        callback({
          id: doc.id,
          ...doc.data()
        } as TeamInterface);
      }
    }, (error) => {
      console.error('Erreur lors de l\'écoute des changements:', error);
    });
}
```

### Interface TeamInterface

```typescript
interface TeamInterface {
  id?: string;
  name: string;
  type: 'DELIVERY' | 'SUPPORT' | 'ADMIN';
  status: 'ACTIVE' | 'INACTIVE';
  members: string[];
  leader?: string;
  description?: string;
  createdAt?: FirebaseFirestore.Timestamp;
  updatedAt?: FirebaseFirestore.Timestamp;
}

interface TeamFilters {
  type?: TeamInterface['type'];
  status?: TeamInterface['status'];
  limit?: number;
  startAfter?: string;
}
```

### Bonnes Pratiques

1. **Gestion des Erreurs**
   - Utiliser le système AppError personnalisé
   - Logger les erreurs pour le débogage
   - Retourner des messages d'erreur appropriés

2. **Transactions**
   - Utiliser les transactions pour les opérations atomiques
   - Vérifier l'existence des documents avant les modifications
   - Gérer les conflits de concurrence

3. **Performance**
   - Utiliser la pagination pour les grandes listes
   - Indexer les champs fréquemment utilisés
   - Minimiser le nombre de requêtes

4. **Sécurité**
   - Valider les données avant l'écriture
   - Utiliser les règles de sécurité Firestore
   - Vérifier les permissions utilisateur
