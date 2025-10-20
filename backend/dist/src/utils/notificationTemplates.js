"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCustomerName = exports.userNotificationTemplates = exports.orderNotificationTemplates = void 0;
exports.orderNotificationTemplates = {
    orderCreated: (order, user) => {
        var _a;
        return ({
            title: 'Nouvelle commande',
            message: `Commande #${order.id} créée avec succès`,
            data: {
                orderId: order.id,
                totalAmount: order.totalAmount,
                customerName: user ? `${user.firstName || ''} ${user.lastName || ''}`.trim() : 'Client',
                items: ((_a = order.items) === null || _a === void 0 ? void 0 : _a.map(item => {
                    var _a;
                    return ({
                        name: ((_a = item.article) === null || _a === void 0 ? void 0 : _a.name) || 'Article',
                        quantity: item.quantity
                    });
                })) || []
            }
        });
    },
    orderStatusUpdate: (order, newStatus) => ({
        title: 'Mise à jour de commande',
        message: `La commande #${order.id} est maintenant ${newStatus}`,
        data: {
            orderId: order.id,
            status: newStatus,
            updatedAt: new Date().toISOString()
        }
    })
};
exports.userNotificationTemplates = {
    welcome: (user) => ({
        title: 'Bienvenue!',
        message: `Bienvenue ${user.firstName || 'utilisateur'} sur notre plateforme!`,
        data: {
            userId: user.id
        }
    })
};
const getCustomerName = (user) => {
    if (!user)
        return 'Client';
    const firstName = user.firstName || '';
    const lastName = user.lastName || '';
    return `${firstName} ${lastName}`.trim() || 'Client';
};
exports.getCustomerName = getCustomerName;
