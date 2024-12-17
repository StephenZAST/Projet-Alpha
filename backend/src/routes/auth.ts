import express from 'express';
import loginRouter from './auth/login';
import googleAuthRouter from './auth/googleAuth';
import testEmailRouter from './auth/testEmail';

const router = express.Router();

router.use('/login', loginRouter);
router.use('/google', googleAuthRouter);
router.use('/test-email', testEmailRouter);

export default router;
