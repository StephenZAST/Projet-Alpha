import NodeCache from 'node-cache';

// Configuration du cache
const cache = new NodeCache({
    stdTTL: 600, // 10 minutes par défaut
    checkperiod: 120, // Vérifier les clés expirées toutes les 2 minutes
    useClones: false // Pour améliorer les performances
});

export class CacheService {
    private static instance: CacheService;
    private cache: NodeCache;

    private constructor() {
        this.cache = cache;
    }

    public static getInstance(): CacheService {
        if (!CacheService.instance) {
            CacheService.instance = new CacheService();
        }
        return CacheService.instance;
    }

    // Obtenir une valeur du cache
    public get<T>(key: string): T | undefined {
        return this.cache.get<T>(key);
    }

    // Définir une valeur dans le cache
    public set<T>(key: string, value: T, ttl?: number): boolean {
        return this.cache.set(key, value, ttl);
    }

    // Supprimer une valeur du cache
    public del(key: string | string[]): number {
        return this.cache.del(key);
    }

    // Vider tout le cache
    public flush(): void {
        this.cache.flushAll();
    }

    // Obtenir plusieurs valeurs
    public mget<T>(keys: string[]): { [key: string]: T } {
        return this.cache.mget<T>(keys);
    }

    // Définir plusieurs valeurs
    public mset<T>(keyValuePairs: { key: string; val: T; ttl?: number }[]): boolean {
        return this.cache.mset(keyValuePairs);
    }

    // Vérifier si une clé existe
    public has(key: string): boolean {
        return this.cache.has(key);
    }

    // Obtenir les statistiques du cache
    public getStats() {
        return this.cache.getStats();
    }

    // Obtenir toutes les clés
    public keys(): string[] {
        return this.cache.keys();
    }

    // Obtenir le nombre d'éléments dans le cache
    public count(): number {
        return this.cache.keys().length;
    }
}

// Middleware pour mettre en cache les réponses HTTP
export const cacheMiddleware = (duration: number = 600) => {
    return (req: any, res: any, next: any) => {
        const key = `__express__${req.originalUrl || req.url}`;
        const cacheService = CacheService.getInstance();
        const cachedResponse = cacheService.get(key);

        if (cachedResponse) {
            res.send(cachedResponse);
            return;
        }

        res.sendResponse = res.send;
        res.send = (body: any) => {
            cacheService.set(key, body, duration);
            res.sendResponse(body);
        };
        next();
    };
};

export default CacheService.getInstance();
