"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.prisma = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const client_1 = require("@prisma/client");
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
// Import all routes
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const order_routes_1 = __importDefault(require("./routes/order.routes"));
const delivery_routes_1 = __importDefault(require("./routes/delivery.routes"));
const affiliate_routes_1 = __importDefault(require("./routes/affiliate.routes"));
const loyalty_routes_1 = __importDefault(require("./routes/loyalty.routes"));
const notification_routes_1 = __importDefault(require("./routes/notification.routes"));
const service_routes_1 = __importDefault(require("./routes/service.routes"));
const address_routes_1 = __importDefault(require("./routes/address.routes"));
const admin_routes_1 = __importDefault(require("./routes/admin.routes"));
const offer_routes_1 = __importDefault(require("./routes/offer.routes"));
const articleCategory_routes_1 = __importDefault(require("./routes/articleCategory.routes"));
const article_routes_1 = __importDefault(require("./routes/article.routes"));
const articleService_routes_1 = __importDefault(require("./routes/articleService.routes"));
const blogCategory_routes_1 = __importDefault(require("./routes/blogCategory.routes"));
const blogArticle_routes_1 = __importDefault(require("./routes/blogArticle.routes"));
const orderItem_routes_1 = __importDefault(require("./routes/orderItem.routes"));
const archive_routes_1 = __importDefault(require("./routes/archive.routes"));
const subscription_routes_1 = __importDefault(require("./routes/subscription.routes"));
const weightPricing_routes_1 = __importDefault(require("./routes/weightPricing.routes"));
const serviceType_routes_1 = __importDefault(require("./routes/serviceType.routes"));
const user_routes_1 = __importDefault(require("./routes/user.routes"));
// Load environment variables
dotenv_1.default.config();
// Initialize Prisma
exports.prisma = new client_1.PrismaClient();
const app = (0, express_1.default)();
// Middleware globaux
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Configure CORS 
const allowedOrigins = [
    'http://localhost:3000', // React default
    'http://localhost:3001', // Your API
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
    'http://localhost:8080', // Common dev port
    'http://localhost:8081', // Common dev port
    'http://localhost:53492', // Flutter web debug
    'http://localhost:51284', // Flutter web debug
    'http://localhost:61846', // Flutter web debug
    /^http:\/\/localhost:\d+$/, // Any localhost port
    /^http:\/\/127\.0\.0\.1:\d+$/ // Any 127.0.0.1 port
];
app.use((0, cors_1.default)({
    origin: (origin, callback) => {
        if (!origin)
            return callback(null, true);
        if (allowedOrigins.some(allowedOrigin => {
            if (allowedOrigin instanceof RegExp) {
                return allowedOrigin.test(origin);
            }
            return allowedOrigin === origin;
        })) {
            callback(null, true);
        }
        else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));
// Rate limiting configuration
const loginLimiter = (0, express_rate_limit_1.default)({
    windowMs: 60 * 60 * 1000, // 1 heure
    max: 20, // 20 tentatives par heure
    message: { message: 'Trop de tentatives de connexion, veuillez réessayer plus tard.' },
    standardHeaders: true,
    legacyHeaders: false,
});
const adminLimiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5000, // limite élevée
    standardHeaders: true,
    legacyHeaders: false,
});
const standardLimiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10000, // limite standard
    standardHeaders: true,
    legacyHeaders: false,
});
// Appliquer les limites par route
app.use('/api/auth/admin/login', loginLimiter);
app.use('/api/admin', adminLimiter);
app.use('/api/orders', adminLimiter);
app.use('/api/notifications', adminLimiter);
app.use('/api', standardLimiter);
// Routes
app.use('/api/auth', auth_routes_1.default);
app.use('/api/orders', order_routes_1.default);
app.use('/api/delivery', delivery_routes_1.default);
app.use('/api/affiliate', affiliate_routes_1.default);
app.use('/api/loyalty', loyalty_routes_1.default);
app.use('/api/notifications', notification_routes_1.default);
app.use('/api/services', service_routes_1.default);
app.use('/api/addresses', address_routes_1.default);
app.use('/api/admin', admin_routes_1.default);
app.use('/api/offers', offer_routes_1.default);
app.use('/api/article-categories', articleCategory_routes_1.default);
app.use('/api/articles', article_routes_1.default);
app.use('/api/article-services', articleService_routes_1.default);
app.use('/api/blog-categories', blogCategory_routes_1.default);
app.use('/api/blog-articles', blogArticle_routes_1.default);
app.use('/api/order-items', orderItem_routes_1.default);
app.use('/api/archives', archive_routes_1.default);
app.use('/api/subscriptions', subscription_routes_1.default);
app.use('/api/weight-pricing', weightPricing_routes_1.default);
app.use('/api/service-types', serviceType_routes_1.default);
app.use('/api/users', user_routes_1.default);
// Ajouter la route health check
app.get('/api/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        message: 'Server is running'
    });
});
// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: err.message,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
});
// Basic route
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to Alpha Laundry API' });
});
// Export the express app for serverless or external servers to consume.
// Server initialization (listening, DB connect, scheduler) should be done
// in a separate entrypoint (e.g., src/server.ts) so that serverless platforms
// like Vercel can import the app without starting a listener.
exports.default = app;
