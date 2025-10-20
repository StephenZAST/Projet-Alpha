# Guide de Déploiement - Alpha Laundry Backend

## Déploiement sur Render

### Prérequis
1. Compte Render (https://render.com)
2. Base de données PostgreSQL (Neon, Render, ou autre)
3. Repository GitHub avec le code

### Étapes de déploiement

#### 1. Créer une base de données PostgreSQL

Sur Render:
- Allez à Dashboard → New → PostgreSQL
- Configurez la base de données
- Notez les URLs de connexion

#### 2. Configurer les variables d'environnement

Sur Render, dans les paramètres du service web:
- Allez à Environment
- Ajoutez les variables suivantes:

```
NODE_ENV=production
PORT=3001
DATABASE_URL=postgresql://user:password@host:5432/database
DIRECT_URL=postgresql://user:password@host:5432/database
JWT_SECRET=your-very-secure-secret-key-here
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_FROM_NAME=Alpha Laundry
EMAIL_FROM_ADDRESS=noreply@alphalaundry.com
GOOGLE_AI_API_KEY=your-google-ai-key
ALLOW_PRICE_PER_KG=true
ALLOW_PREMIUM_PRICES=true
MIN_BASE_PRICE=100
MAX_PREMIUM_MULTIPLIER=3
PRICE_ROUNDING_DECIMAL=2
PRICE_CACHE_DURATION=3600
POINTS_TO_DISCOUNT_RATE=0.1
MAX_POINTS_DISCOUNT_PERCENTAGE=30
```

#### 3. Créer le service web sur Render

1. Allez à Dashboard → New → Web Service
2. Connectez votre repository GitHub
3. Configurez:
   - **Name**: alpha-laundry-backend
   - **Runtime**: Node
   - **Region**: Oregon (ou votre région)
   - **Branch**: main
   - **Root Directory**: backend
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
   - **Plan**: Free (ou payant selon vos besoins)

4. Cliquez sur "Create Web Service"

#### 4. Vérifier le déploiement

Après le déploiement:
1. Vérifiez les logs pour les erreurs
2. Testez l'endpoint health: `https://your-app.onrender.com/api/health`
3. Vérifiez la connexion à la base de données

### Dépannage

#### Erreur: "Build failed"
- Vérifiez que le `package.json` a les bons scripts
- Vérifiez que `render.yaml` est à la racine du projet
- Vérifiez les logs pour plus de détails

#### Erreur: "Cannot find module"
- Assurez-vous que `npm install` s'exécute
- Vérifiez que toutes les dépendances sont dans `package.json`

#### Erreur: "Database connection failed"
- Vérifiez les variables `DATABASE_URL` et `DIRECT_URL`
- Assurez-vous que la base de données est accessible
- Vérifiez les pare-feu et les règles de sécurité

#### Erreur: "Prisma migration failed"
- Les migrations doivent être appliquées manuellement
- Utilisez: `npx prisma db push` en local avant de déployer

### Mise à jour du déploiement

Pour mettre à jour après des changements:
1. Poussez les changements sur GitHub
2. Render redéploiera automatiquement
3. Vérifiez les logs pour les erreurs

### Commandes utiles

```bash
# Générer le client Prisma
npm run prisma:generate

# Appliquer les migrations
npm run prisma:push

# Compiler TypeScript
npm run build

# Démarrer le serveur
npm start

# Développement local
npm run dev
```

### Structure du projet

```
Alpha/
├── backend/
│   ├── src/
│   ├── prisma/
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
├── render.yaml
└── DEPLOYMENT.md
```

### Notes importantes

1. **Sécurité**: Utilisez des secrets forts pour `JWT_SECRET`
2. **Base de données**: Utilisez une base de données PostgreSQL en production
3. **Logs**: Consultez les logs Render pour le dépannage
4. **Monitoring**: Configurez les alertes pour les erreurs de déploiement
5. **Backups**: Configurez les backups automatiques de la base de données

### Support

Pour plus d'aide:
- Documentation Render: https://render.com/docs
- Documentation Prisma: https://www.prisma.io/docs
- Documentation Express: https://expressjs.com
