export * from './custom';
export * from './error.types';

// Export des types Google Trends
export type { TrendsApiOptions, TrendsResult } from 'google-trends-api';

// Re-export des types communs pour faciliter l'importation
export type { Request, Response, NextFunction } from 'express';
 