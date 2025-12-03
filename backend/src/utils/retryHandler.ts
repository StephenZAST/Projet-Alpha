/**
 * 🔄 Retry Handler - Gestion robuste des retries avec backoff exponentiel
 */

export interface RetryOptions {
  maxAttempts?: number;
  initialDelayMs?: number;
  maxDelayMs?: number;
  backoffMultiplier?: number;
  jitter?: boolean;
}

export class RetryHandler {
  private static readonly DEFAULT_OPTIONS: Required<RetryOptions> = {
    maxAttempts: 3,
    initialDelayMs: 1000,
    maxDelayMs: 30000,
    backoffMultiplier: 2,
    jitter: true
  };

  /**
   * Exécuter une fonction avec retry automatique
   */
  static async execute<T>(
    fn: () => Promise<T>,
    options: RetryOptions = {}
  ): Promise<T> {
    const opts = { ...this.DEFAULT_OPTIONS, ...options };
    let lastError: Error | null = null;

    for (let attempt = 1; attempt <= opts.maxAttempts; attempt++) {
      try {
        console.log(`[RetryHandler] Tentative ${attempt}/${opts.maxAttempts}`);
        const result = await fn();
        console.log(`[RetryHandler] ✅ Succès à la tentative ${attempt}`);
        return result;
      } catch (error: any) {
        lastError = error;
        console.error(`[RetryHandler] ❌ Tentative ${attempt} échouée:`, error.message);

        // Si c'est la dernière tentative, ne pas attendre
        if (attempt === opts.maxAttempts) {
          break;
        }

        // Calculer le délai d'attente
        const delayMs = this.calculateDelay(attempt, opts);
        console.log(`[RetryHandler] ⏳ Attente de ${delayMs}ms avant la prochaine tentative...`);
        await this.sleep(delayMs);
      }
    }

    throw new Error(
      `Failed after ${opts.maxAttempts} attempts. Last error: ${lastError?.message}`
    );
  }

  /**
   * Calculer le délai avec backoff exponentiel et jitter
   */
  private static calculateDelay(attempt: number, opts: Required<RetryOptions>): number {
    // Backoff exponentiel : initialDelay * (multiplier ^ (attempt - 1))
    let delay = opts.initialDelayMs * Math.pow(opts.backoffMultiplier, attempt - 1);

    // Limiter au délai maximum
    delay = Math.min(delay, opts.maxDelayMs);

    // Ajouter du jitter (randomness) pour éviter les thundering herd
    if (opts.jitter) {
      const jitterAmount = delay * 0.1; // 10% de jitter
      delay += Math.random() * jitterAmount;
    }

    return Math.floor(delay);
  }

  /**
   * Attendre un certain temps
   */
  private static sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Exécuter avec retry et timeout
   */
  static async executeWithTimeout<T>(
    fn: () => Promise<T>,
    timeoutMs: number = 30000,
    retryOptions: RetryOptions = {}
  ): Promise<T> {
    return Promise.race([
      this.execute(fn, retryOptions),
      new Promise<T>((_, reject) =>
        setTimeout(
          () => reject(new Error(`Operation timed out after ${timeoutMs}ms`)),
          timeoutMs
        )
      )
    ]);
  }

  /**
   * Exécuter plusieurs fonctions en parallèle avec retry
   */
  static async executeParallel<T>(
    fns: Array<() => Promise<T>>,
    options: RetryOptions = {}
  ): Promise<T[]> {
    return Promise.all(fns.map(fn => this.execute(fn, options)));
  }

  /**
   * Exécuter avec fallback
   */
  static async executeWithFallback<T>(
    primaryFn: () => Promise<T>,
    fallbackFn: () => Promise<T>,
    primaryRetryOptions: RetryOptions = {}
  ): Promise<T> {
    try {
      return await this.execute(primaryFn, primaryRetryOptions);
    } catch (error) {
      console.log('[RetryHandler] Primary function failed, using fallback');
      return await fallbackFn();
    }
  }
}
