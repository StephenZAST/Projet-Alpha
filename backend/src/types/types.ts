export type UserCredentials = {
  email: string;
  password: string;
  user_metadata?: {
    [key: string]: any;
  };
};
