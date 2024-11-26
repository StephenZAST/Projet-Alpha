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
