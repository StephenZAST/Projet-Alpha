export const errorCodes = {
  ARTICLE_NOT_FOUND: 'ARTICLE_NOT_FOUND',
  INVALID_ARTICLE_DATA: 'INVALID_ARTICLE_DATA',
  DATABASE_ERROR: 'DATABASE_ERROR',
  UNAUTHORIZED: 'UNAUTHORIZED',
  INVALID_PRICE_RANGE: 'INVALID_PRICE_RANGE',
  INVALID_SERVICE: 'INVALID_SERVICE',
  // Add other error codes as needed
} as const;

export class AppError extends Error {
  statusCode: number;
  errorCode: string;

  constructor(statusCode: number, message: string, errorCode: string) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
  }
}
