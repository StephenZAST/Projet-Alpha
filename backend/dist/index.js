"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const users_1 = __importDefault(require("./routes/users"));
const orders_1 = __importDefault(require("./routes/orders"));
const articles_1 = __importDefault(require("./routes/articles"));
const notifications_1 = __importDefault(require("./routes/notifications"));
const categories_1 = __importDefault(require("./routes/categories"));
const subscriptions_1 = __importDefault(require("./routes/subscriptions"));
const config_1 = require("./config");
const app = (0, express_1.default)();
const port = config_1.config.port || 3001;
// Rate limiting configuration
const limiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});
// Security middleware
app.use((0, helmet_1.default)()); // Adds various HTTP headers for security
app.use((0, cors_1.default)({
    origin: config_1.config.allowedOrigins || '*', // Configure your allowed origins
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
}));
// Apply rate limiting to all requests
app.use(limiter);
// Body parsing middleware
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true }));
// Routes
app.use('/api/users', users_1.default);
app.use('/api/orders', orders_1.default);
app.use('/api/articles', articles_1.default);
app.use('/api/notifications', notifications_1.default);
app.use('/api/categories', categories_1.default);
app.use('/api/subscriptions', subscriptions_1.default);
// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
