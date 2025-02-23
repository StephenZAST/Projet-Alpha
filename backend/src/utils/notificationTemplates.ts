
import { Order, User } from '../models/types';

export const orderNotificationTemplates = {
  orderCreated: (order: Order, user?: User) => ({
    title: 'Nouvelle commande',
    message: `Commande #${order.id} créée avec succès`,
    data: {
      orderId: order.id,
      totalAmount: order.totalAmount,
      customerName: user ? `${user.firstName || ''} ${user.lastName || ''}`.trim() : 'Client',
      items: order.items?.map(item => ({
        name: item.article?.name || 'Article',
        quantity: item.quantity
      })) || []
    }
  }),

  orderStatusUpdate: (order: Order, newStatus: string) => ({
    title: 'Mise à jour de commande',
    message: `La commande #${order.id} est maintenant ${newStatus}`,
    data: {
      orderId: order.id,
      status: newStatus,
      updatedAt: new Date().toISOString()
    }
  })
};

export const userNotificationTemplates = {
  welcome: (user: User) => ({
    title: 'Bienvenue!', 
    message: `Bienvenue ${user.firstName || 'utilisateur'} sur notre plateforme!`,
    data: {
      userId: user.id
    }
  })
};

export const getCustomerName = (user?: User): string => {
  if (!user) return 'Client';
  const firstName = user.firstName || '';
  const lastName = user.lastName || '';
  return `${firstName} ${lastName}`.trim() || 'Client';
};
 