import { NextFunction, Request, Response } from 'express';

export const validateBlogGenerationConfig = (req: Request, res: Response, next: NextFunction) => {
    // TO DO: implement validation logic here
    next();
};
