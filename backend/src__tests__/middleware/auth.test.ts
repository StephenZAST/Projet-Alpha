import { authenticateUser, requireAdmin } from '../middleware/auth';
import { verifyToken } from '../services/firebase';
import { createMockRequest, createMockResponse } from '../utils/express';

jest.mock('../../services/firebase');

describe('Auth Middleware', () => {
  test('authenticateUser validates token', async () => {
    const mockReq = createMockRequest({
      headers: { authorization: 'Bearer valid-token' }
    });
    const mockRes = createMockResponse();
    const mockNext = jest.fn();

    (verifyToken as jest.Mock).mockResolvedValue({
      uid: '123',
      role: 'user'
    });

    await authenticateUser(mockReq, mockRes, mockNext);
    expect(mockReq.user).toBeDefined();
    expect(mockNext).toHaveBeenCalled();
  });

  test('requireAdmin blocks non-admin users', async () => {
    const mockReq = createMockRequest({
      user: { role: 'user' }
    });
    const mockRes = createMockResponse();
    const mockNext = jest.fn();

    requireAdmin(mockReq, mockRes, mockNext);
    expect(mockRes.status).toHaveBeenCalledWith(403);
  });
});
