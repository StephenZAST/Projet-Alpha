Let me help you create a comprehensive Markdown documentation of the backend application's features.

Alpha Backend Documentation
Core Features & Services
1. Authentication & User Management
Core Location: auth.service.ts Related Controllers: auth.controller.ts Endpoints:


POST /api/auth/register        # User registration
POST /api/auth/login          # User login 
POST /api/auth/admin/login    # Admin login
GET /api/auth/me              # Get current user
POST /api/auth/logout         # User logout
POST /api/auth/become-affiliate # Register as affiliate
PATCH /api/auth/update-profile # Update user profile
POST /api/auth/change-password # Change password
DELETE /api/auth/delete-account # Delete account


2. Order Management
Core Location: services/order.service/


order.service.ts - Main service
orderCreate.service.ts - Order creation
orderQuery.service.ts - Order queries
orderStatus.service.ts - Status management

Related Controllers: controllers/order.controller/ Endpoints:


POST /api/orders/             # Create new order
GET /api/orders/my-orders     # Get user's orders
GET /api/orders/:orderId      # Get order details
GET /api/orders/recent        # Get recent orders
GET /api/orders/by-status     # Get orders by status
PATCH /api/orders/:orderId/status # Update order status


3. Affiliate System
Core Location: services/affiliate.service/

affiliateProfile.service.ts
affiliateCommission.service.ts
affiliateWithdrawal.service.ts
Related Controllers: affiliate.controller.ts Endpoints:

GET /api/affiliate/profile    # Get affiliate profile
PUT /api/affiliate/profile    # Update profile
GET /api/affiliate/commissions # Get commissions
POST /api/affiliate/withdrawal # Request withdrawal
GET /api/affiliate/referrals   # Get referrals
GET /api/affiliate/levels      # Get affiliate levels
GET /api/affiliate/current-level # Get current level
POST /api/affiliate/generate-code # Generate affiliate code


4. Product & Service Management
Services:

article.service.ts
service.service.ts
articleService.service.ts
Controllers:

article.controller.ts
service.controller.ts
articleService.controller.ts
Endpoints:


# Articles
GET /api/articles/
POST /api/articles/
GET /api/articles/:articleId
PATCH /api/articles/:articleId
DELETE /api/articles/:articleId

# Services
GET /api/services/all
POST /api/services/create
PATCH /api/services/update/:serviceId
DELETE /api/services/delete/:serviceId



5. Loyalty System
Core Location: loyalty.service.ts Controller: loyalty.controller.ts Endpoints:


POST /api/loyalty/earn-points
POST /api/loyalty/spend-points
GET /api/loyalty/points-balance


6. Notifications
Core Location: notification.service.ts Controller: notification.controller.ts Endpoints:


GET /api/notifications/
GET /api/notifications/unread
PATCH /api/notifications/:notificationId/read
DELETE /api/notifications/:notificationId
POST /api/notifications/mark-all-read


7. Admin Dashboard
Core Location: admin.service.ts Controller: admin.controller.ts Endpoints:


GET /api/admin/statistics
GET /api/admin/revenue-chart
POST /api/admin/configure-commissions
POST /api/admin/configure-rewards
GET /api/admin/total-revenue
GET /api/admin/total-customers


8. Blog System
Services:

blogArticle.service.ts
blogCategory.service.ts
Controllers:

blogArticle.controller.ts
blogCategory.controller.ts
Endpoints:


GET /api/blog-articles/
POST /api/blog-articles/
PUT /api/blog-articles/:articleId
DELETE /api/blog-articles/:articleId
POST /api/blog-articles/generate


9. Delivery Management
Core Location: delivery.service.ts Controller: delivery.controller.ts Endpoints:


GET /api/delivery/pending-orders
GET /api/delivery/assigned-orders
PATCH /api/delivery/:orderId/status
GET /api/delivery/collected-orders
GET /api/delivery/processing-orders
GET /api/delivery/ready-orders
GET /api/delivery/delivering-orders
GET /api/delivery/delivered-orders



10. Special Offers
Core Location: offer.service.ts Controller: offer.controller.ts Endpoints:



GET /api/offers/available
POST /api/offers/
PUT /api/offers/:offerId
DELETE /api/offers/:offerId
PATCH /api/offers/:offerId/status


hared Utilities
Database Configuration: database.ts
Authentication Middleware: auth.middleware.ts
Input Validation: validators.ts
Pagination Utils: pagination.ts
Email Templates: emailTemplates.ts
Async Handler: asyncHandler.ts
Scheduled Tasks
Location: scheduler.ts

Daily blog article generation
Monthly affiliate earnings reset
This backend application provides a comprehensive suite of features for an e-commerce laundry service with affiliate marketing capabilities, loyalty programs, and content management. All components are modular and follow clean architecture principles.
