export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public code?: string
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export const errorCodes = {
  ARTICLE_NOT_FOUND: 'ARTICLE_NOT_FOUND',
  INVALID_ARTICLE_DATA: 'INVALID_ARTICLE_DATA',
  DATABASE_ERROR: 'DATABASE_ERROR',
  UNAUTHORIZED: 'UNAUTHORIZED'
} as const;
