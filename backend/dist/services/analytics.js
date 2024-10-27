"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AnalyticsService = void 0;
const firebase_1 = require("./firebase");
class AnalyticsService {
    constructor() {
        this.ordersRef = firebase_1.db.collection('orders');
        this.usersRef = firebase_1.db.collection('users');
        this.affiliatesRef = firebase_1.db.collection('affiliates');
    }
    getRevenueMetrics(startDate, endDate) {
        return __awaiter(this, void 0, void 0, function* () {
            const ordersSnapshot = yield this.ordersRef
                .where('createdAt', '>=', startDate)
                .where('createdAt', '<=', endDate)
                .get();
            const orders = ordersSnapshot.docs.map(doc => doc.data());
            const totalRevenue = orders.reduce((sum, order) => sum + order.totalAmount, 0);
            const averageOrderValue = totalRevenue / orders.length || 0;
            const revenueByService = orders.reduce((acc, order) => {
                order.items.forEach((item) => {
                    acc[item.service] = (acc[item.service] || 0) + item.totalPrice;
                });
                return acc;
            }, {});
            return {
                totalRevenue,
                periodRevenue: totalRevenue,
                orderCount: orders.length,
                averageOrderValue,
                revenueByService,
                periodStart: startDate,
                periodEnd: endDate
            };
        });
    }
    getCustomerMetrics() {
        return __awaiter(this, void 0, void 0, function* () {
            const customersSnapshot = yield this.usersRef
                .where('role', '==', 'customer')
                .get();
            const customers = customersSnapshot.docs.map(doc => doc.data());
            const activeCustomers = customers.filter(customer => customer.lastOrderDate &&
                new Date(customer.lastOrderDate) >= new Date(Date.now() - 90 * 24 * 60 * 60 * 1000));
            const topCustomers = customers
                .sort((a, b) => b.totalSpent - a.totalSpent)
                .slice(0, 10)
                .map(customer => ({
                userId: customer.id,
                totalSpent: customer.totalSpent,
                orderCount: customer.orderCount,
                loyaltyTier: customer.loyaltyTier,
                lastOrderDate: customer.lastOrderDate
            }));
            return {
                totalCustomers: customers.length,
                activeCustomers: activeCustomers.length,
                customerRetentionRate: (activeCustomers.length / customers.length) * 100,
                topCustomers,
                customersByTier: this.groupCustomersByTier(customers)
            };
        });
    }
    getAffiliateMetrics(startDate, endDate) {
        return __awaiter(this, void 0, void 0, function* () {
            const affiliatesSnapshot = yield this.affiliatesRef.get();
            const affiliates = affiliatesSnapshot.docs.map(doc => doc.data());
            const topAffiliates = yield this.calculateTopAffiliates(affiliates, startDate, endDate);
            return {
                totalAffiliates: affiliates.length,
                activeAffiliates: affiliates.filter(a => a.activeCustomers > 0).length,
                totalCommissions: affiliates.reduce((sum, a) => sum + a.totalCommission, 0),
                topAffiliates,
                commissionsPerPeriod: yield this.calculateCommissionsPerPeriod(startDate, endDate)
            };
        });
    }
    calculateTopAffiliates(affiliates, startDate, endDate) {
        return __awaiter(this, void 0, void 0, function* () {
            // Implementation for calculating top affiliate performance
            return [];
        });
    }
    calculateCommissionsPerPeriod(startDate, endDate) {
        return __awaiter(this, void 0, void 0, function* () {
            // Implementation for calculating commissions per period
            return {};
        });
    }
    groupCustomersByTier(customers) {
        return customers.reduce((acc, customer) => {
            acc[customer.loyaltyTier] = (acc[customer.loyaltyTier] || 0) + 1;
            return acc;
        }, {});
    }
}
exports.AnalyticsService = AnalyticsService;
