import jwt from 'jsonwebtoken';

const testToken = jwt.sign(
  {
    id: 'admin-test-id',
    role: 'ADMIN',
    email: 'admin@test.com'
  },
  process.env.JWT_SECRET || 'your-secret-key',
  { expiresIn: '1h' }
);

console.log('Test Token:', testToken);
