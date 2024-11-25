# Composants Réutilisables Frontend

Ce document détaille les composants et fonctionnalités réutilisables qui peuvent être implémentés dans le frontend de l'application Alpha Laundry.

## 1. Composants UI Communs

### 1.1 Tables Dynamiques
```typescript
interface DataTableProps<T> {
  data: T[];
  columns: TableColumn[];
  pagination?: boolean;
  sorting?: boolean;
  filtering?: boolean;
  actions?: TableAction[];
  onRowClick?: (row: T) => void;
}
```
**Utilisations:**
- Liste des commandes
- Liste des utilisateurs
- Liste des équipes
- Historique des transactions
- Rapports

### 1.2 Formulaires Dynamiques
```typescript
interface DynamicFormProps {
  fields: FormField[];
  initialValues?: Record<string, any>;
  validation?: ValidationSchema;
  onSubmit: (values: any) => void;
  layout?: 'vertical' | 'horizontal';
}
```
**Utilisations:**
- Création/édition d'utilisateur
- Création de commande
- Configuration des services
- Paramètres du système

### 1.3 Cartes Statistiques
```typescript
interface StatCardProps {
  title: string;
  value: number | string;
  icon?: IconType;
  trend?: {
    value: number;
    direction: 'up' | 'down';
  };
  period?: string;
}
```
**Utilisations:**
- Dashboard KPIs
- Rapports de performance
- Métriques d'équipe
- Statistiques de vente

## 2. Services Partagés

### 2.1 Service d'Authentication
```typescript
class AuthService {
  login(credentials: LoginCredentials): Promise<User>;
  logout(): void;
  refreshToken(): Promise<string>;
  getCurrentUser(): User | null;
  checkPermission(permission: string): boolean;
}
```

### 2.2 Service de Gestion d'État
```typescript
class StateManager {
  setGlobalState(key: string, value: any): void;
  getGlobalState(key: string): any;
  subscribe(key: string, callback: (value: any) => void): void;
  clearState(): void;
}
```

### 2.3 Service de Notification
```typescript
interface NotificationService {
  success(message: string, options?: NotificationOptions): void;
  error(message: string, options?: NotificationOptions): void;
  warning(message: string, options?: NotificationOptions): void;
  info(message: string, options?: NotificationOptions): void;
}
```

## 3. Hooks Personnalisés

### 3.1 useAPI
```typescript
function useAPI<T>(endpoint: string, options?: APIOptions) {
  return {
    data: T | null;
    loading: boolean;
    error: Error | null;
    refetch: () => Promise<void>;
  };
}
```

### 3.2 usePermissions
```typescript
function usePermissions(requiredPermissions: string[]) {
  return {
    hasAccess: boolean;
    isLoading: boolean;
    userPermissions: string[];
  };
}
```

### 3.3 useForm
```typescript
function useForm<T>(options: FormOptions) {
  return {
    values: T;
    errors: FormErrors;
    touched: TouchedFields;
    handleChange: (field: string, value: any) => void;
    handleSubmit: (e: FormEvent) => void;
    reset: () => void;
  };
}
```

## 4. Utilitaires

### 4.1 Gestionnaire de Routes
```typescript
interface RouteConfig {
  path: string;
  component: ComponentType;
  permissions?: string[];
  layout?: LayoutType;
  children?: RouteConfig[];
}
```

### 4.2 Intercepteur HTTP
```typescript
class HTTPInterceptor {
  beforeRequest(config: RequestConfig): RequestConfig;
  afterResponse(response: Response): Response;
  onError(error: Error): Promise<void>;
}
```

### 4.3 Gestionnaire de Cache
```typescript
interface CacheManager {
  set(key: string, value: any, ttl?: number): void;
  get<T>(key: string): T | null;
  remove(key: string): void;
  clear(): void;
}
```

## 5. Layouts Réutilisables

### 5.1 Layout Principal
```typescript
interface MainLayoutProps {
  sidebar?: boolean;
  header?: boolean;
  footer?: boolean;
  children: ReactNode;
}
```

### 5.2 Layout de Dashboard
```typescript
interface DashboardLayoutProps {
  title: string;
  breadcrumbs?: Breadcrumb[];
  actions?: Action[];
  filters?: Filter[];
  children: ReactNode;
}
```

## 6. Modules Fonctionnels

### 6.1 Module de Gestion des Fichiers
```typescript
interface FileManager {
  upload(file: File): Promise<string>;
  download(url: string): Promise<Blob>;
  preview(url: string): void;
  delete(url: string): Promise<void>;
}
```

### 6.2 Module de Rapports
```typescript
interface ReportGenerator {
  generatePDF(data: any): Promise<Blob>;
  generateExcel(data: any): Promise<Blob>;
  preview(report: Report): void;
  schedule(report: Report, schedule: Schedule): void;
}
```

## 7. Directives d'Implémentation

### 7.1 Standards de Code
- Utiliser TypeScript pour tout le code
- Suivre les principes SOLID
- Implémenter des tests unitaires
- Documenter avec JSDoc

### 7.2 Gestion d'État
- Utiliser Redux pour l'état global
- Context API pour l'état local
- Persistence locale avec localStorage

### 7.3 Styles
- Utiliser Tailwind CSS
- Système de design tokens
- Thèmes personnalisables
- Mode sombre/clair

### 7.4 Performance
- Lazy loading des composants
- Mise en cache des requêtes API
- Optimisation des images
- Code splitting

## 8. Sécurité

### 8.1 Protection des Routes
```typescript
interface RouteGuard {
  canActivate(): boolean | Promise<boolean>;
  canDeactivate(): boolean | Promise<boolean>;
  redirect?: string;
}
```

### 8.2 Validation des Données
```typescript
interface ValidationService {
  validate(data: any, schema: ValidationSchema): ValidationResult;
  sanitize(data: any, rules: SanitizationRules): any;
}
```

## 9. Internationalisation

### 9.1 Service de Traduction
```typescript
interface TranslationService {
  translate(key: string, params?: object): string;
  changeLanguage(lang: string): void;
  getCurrentLanguage(): string;
}
```

## 10. Analytics

### 10.1 Service de Tracking
```typescript
interface AnalyticsService {
  trackEvent(event: string, params?: object): void;
  trackPageView(page: string): void;
  trackError(error: Error): void;
}
```
