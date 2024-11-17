export default class AppError extends Error {
    constructor(
        message: string,
        public statusCode: number,
        public code: string = 'INTERNAL_SERVER_ERROR'
    ) {
        super(message);
        this.name = 'AppError';
        Error.captureStackTrace(this, this.constructor);
    }
}
