import { User } from '../../models/user';

declare module 'express' {
  interface Request {
    user?: User;
  }
}
