"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.debugMiddleware = void 0;
const debugMiddleware = (req, res, next) => {
    var _a;
    console.log('\n🔍 [DEBUG] Request Details:');
    console.log('Method:', req.method);
    console.log('URL:', req.url);
    console.log('Headers:', {
        authorization: req.headers.authorization ? 'Bearer [TOKEN_PRESENT]' : 'NO_TOKEN',
        'content-type': req.headers['content-type'],
        'user-agent': ((_a = req.headers['user-agent']) === null || _a === void 0 ? void 0 : _a.substring(0, 50)) + '...'
    });
    console.log('Body:', req.body);
    console.log('Query:', req.query);
    console.log('User:', req.user ? { id: req.user.id, role: req.user.role } : 'NO_USER');
    console.log('---\n');
    next();
};
exports.debugMiddleware = debugMiddleware;
