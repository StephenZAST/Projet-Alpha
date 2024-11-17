import { Request, Response, NextFunction } from 'express';
import AppError from '../utils/AppError';
import { errorCodes } from '../utils/errors'; // Import errorCodes

interface IError extends Error {
    statusCode?: number;
    status?: string;
    isOperational?: boolean;
    code?: string; // Change code property to string
    path?: string;
    value?: string;
    errors?: any;
}

const handleCastErrorDB = (err: any) => {
    const message = `Invalid ${err.path}: ${err.value}`;
    return new AppError(message, 400, errorCodes.DATABASE_ERROR); // Add error code
};

const handleDuplicateFieldsDB = (err: any) => {
    const value = err.errmsg.match(/(["'])(\\?.)*?\1/)[0];
    const message = `Duplicate field value: ${value}. Please use another value!`;
    return new AppError(message, 400, errorCodes.DATABASE_ERROR); // Add error code
};

const handleValidationErrorDB = (err: any) => {
    const errors = Object.values(err.errors).map((el: any) => el.message);
    const message = `Invalid input data. ${errors.join('. ')}`;
    return new AppError(message, 400, errorCodes.VALIDATION_ERROR); // Add error code
};

const handleJWTError = () => new AppError('Invalid token. Please log in again!', 401, errorCodes.UNAUTHORIZED); // Add error code

const handleJWTExpiredError = () => new AppError('Your token has expired! Please log in again.', 401, errorCodes.UNAUTHORIZED); // Add error code

const sendErrorDev = (err: IError, res: Response) => {
    res.status(err.statusCode || 500).json({
        status: err.status,
        error: err,
        message: err.message,
        stack: err.stack
    });
};

const sendErrorProd = (err: IError, res: Response) => {
    if (err.isOperational) {
        res.status(err.statusCode || 500).json({
            status: err.status,
            message: err.message
        });
    } else {
        console.error('ERROR 💥', err);
        res.status(500).json({
            status: 'error',
            message: 'Something went very wrong!'
        });
    }
};

export default (err: IError, req: Request, res: Response, next: NextFunction) => {
    err.statusCode = err.statusCode || 500;
    err.status = err.status || 'error';

    if (process.env.NODE_ENV === 'development') {
        sendErrorDev(err, res);
    } else {
        let error = { ...err };
        error.message = err.message;

        if (error.name === 'CastError') error = handleCastErrorDB(error);
        if (error.code === "11000") error = handleDuplicateFieldsDB(error); // Compare as string
        if (error.name === 'ValidationError') error = handleValidationErrorDB(error);
        if (error.name === 'JsonWebTokenError') error = handleJWTError();
        if (error.name === 'TokenExpiredError') error = handleJWTExpiredError();

        sendErrorProd(error, res);
    }
};
