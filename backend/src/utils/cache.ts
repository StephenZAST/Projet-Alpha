import NodeCache from 'node-cache';

// Cache configuration
const defaultCache = new NodeCache({
    stdTTL: 600, // 10 minutes default
    checkperiod: 120, // Check expired keys every 2 minutes
    useClones: false // For better performance
});

export class Cache<K = string, V = any> {
    private cache: NodeCache;

    constructor(ttl: number = 600) {
        this.cache = new NodeCache({
            stdTTL: ttl,
            checkperiod: Math.min(ttl / 5, 120), // Check period is 1/5 of TTL or 2 minutes, whichever is smaller
            useClones: false
        });
    }

    // Get a value from cache
    public get(key: K): V | undefined {
        const stringKey = this.getStringKey(key);
        return this.cache.get<V>(stringKey);
    }

    // Set a value in cache
    public set(key: K, value: V, ttl: number = 0): boolean {
        const stringKey = this.getStringKey(key);
        return this.cache.set(stringKey, value, ttl);
    }

    // Delete a value from cache
    public del(key: K | K[]): number {
        const keys = Array.isArray(key) ? key.map(k => this.getStringKey(k)) : this.getStringKey(key);
        return this.cache.del(keys);
    }

    // Clear entire cache
    public flush(): void {
        this.cache.flushAll();
    }

    // Get multiple values
    public mget(keys: K[]): { [key: string]: V } {
        const stringKeys = keys.map(k => this.getStringKey(k));
        return this.cache.mget<V>(stringKeys);
    }

    // Set multiple values
    public mset(items: { key: K; val: V; ttl?: number }[]): boolean {
        const keyValuePairs = items.map(item => ({
            key: this.getStringKey(item.key),
            val: item.val,
            ttl: item.ttl
        }));
        return this.cache.mset(keyValuePairs);
    }

    // Get stats about cache usage
    public getStats() {
        return {
            keys: this.cache.keys(),
            stats: this.cache.getStats(),
            hits: this.cache.stats.hits,
            misses: this.cache.stats.misses,
            hitRate: this.cache.stats.hits / (this.cache.stats.hits + this.cache.stats.misses)
        };
    }

    private getStringKey(key: K): string {
        if (typeof key === 'string') {
            return key;
        }
        if (typeof key === 'number') {
            return key.toString();
        }
        return JSON.stringify(key);
    }
}

// Legacy singleton instance for backward compatibility
export class CacheService {
    private static instance: CacheService;
    private cache: NodeCache;

    private constructor() {
        this.cache = defaultCache;
    }

    public static getInstance(): CacheService {
        if (!CacheService.instance) {
            CacheService.instance = new CacheService();
        }
        return CacheService.instance;
    }

    public get<T>(key: string): T | undefined {
        return this.cache.get<T>(key);
    }

    public set<T>(key: string, value: T, ttl: number = 0): boolean {
        return this.cache.set(key, value, ttl);
    }

    public del(key: string | string[]): number {
        return this.cache.del(key);
    }

    public flush(): void {
        this.cache.flushAll();
    }

    public mget<T>(keys: string[]): { [key: string]: T } {
        return this.cache.mget<T>(keys);
    }

    public mset<T>(keyValuePairs: { key: string; val: T; ttl?: number }[]): boolean {
        return this.cache.mset(keyValuePairs);
    }
}

// HTTP response caching middleware
export function cacheMiddleware(duration: number = 600) {
    const cache = new Cache(duration);
    
    return (req: any, res: any, next: any) => {
        // Only cache GET requests
        if (req.method !== 'GET') {
            return next();
        }

        const key = req.originalUrl || req.url;
        const cachedResponse = cache.get(key);

        if (cachedResponse) {
            return res.send(cachedResponse);
        }

        // Store original send
        const originalSend = res.send;

        // Override send
        res.send = function(body: any): any {
            originalSend.call(this, body);
            cache.set(key, body);
        };

        next();
    };
}

// Export singleton instance for backward compatibility
export default CacheService.getInstance();
