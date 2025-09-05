import { Request, Response, NextFunction } from 'express';

export const debugMiddleware = (req: Request, res: Response, next: NextFunction) => {
  console.log('\n🔍 [DEBUG] Request Details:');
  console.log('Method:', req.method);
  console.log('URL:', req.url);
  console.log('Headers:', {
    authorization: req.headers.authorization ? 'Bearer [TOKEN_PRESENT]' : 'NO_TOKEN',
    'content-type': req.headers['content-type'],
    'user-agent': req.headers['user-agent']?.substring(0, 50) + '...'
  });
  console.log('Body:', req.body);
  console.log('Query:', req.query);
  console.log('User:', req.user ? { id: req.user.id, role: req.user.role } : 'NO_USER');
  console.log('---\n');
  
  next();
};