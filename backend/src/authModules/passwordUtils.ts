import * as bcrypt from 'bcryptjs';

export const hashPassword = async (password: string): Promise<string> => {
  // Hash a password using bcryptjs
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
};

export const comparePassword = async (password: string, hashedPassword: string): Promise<boolean> => {
  // Compare a password with a hashed password using bcryptjs
  return await bcrypt.compare(password, hashedPassword);
};
