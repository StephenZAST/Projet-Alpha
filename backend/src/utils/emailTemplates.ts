import { Order, NotificationType } from '../models/types';

export const orderConfirmationTemplate = (order: Order) => `
  <h1>Confirmation de commande - Alpha Laundry</h1>
  <p>Votre commande #${order.id} a été reçue avec succès.</p>
  <h2>Détails de la commande :</h2>
  <ul>
    ${order.items?.map(item => `
      <li>${item.quantity} x ${item.article?.name ?? 'Article inconnu'}</li>
    `).join('')}
  </ul>
  <p>Total: ${order.totalAmount}€</p>
  <p>Statut: ${order.status}</p>
`;

export const orderStatusUpdateTemplate = (order: Order, newStatus: string) => `
  <h1>Mise à jour de votre commande - Alpha Laundry</h1>
  <p>Le statut de votre commande #${order.id} a été mis à jour.</p>
  <p>Nouveau statut: ${newStatus}</p>
`;

export const notificationEmailTemplate = (title: string, message: string, type: NotificationType) => `
  <h1>${title}</h1>
  <p>${message}</p>
  <div style="margin-top: 20px; font-size: 12px; color: #666;">
    <p>Type de notification: ${type}</p>
    <p>Pour gérer vos préférences de notifications, connectez-vous à votre compte.</p>
  </div>
`;

export const welcomeNotificationTemplate = (firstName: string) => `
  <h1>Bienvenue sur Alpha Laundry!</h1>
  <p>Bonjour ${firstName},</p>
  <p>Nous sommes ravis de vous accueillir. Vous pouvez maintenant:</p>
  <ul>
    <li>Gérer vos préférences de notification dans votre profil</li>
    <li>Choisir les types de notifications que vous souhaitez recevoir</li>
    <li>Activer ou désactiver les notifications par email, SMS ou push</li>
  </ul>
  <p>N'hésitez pas à personnaliser vos préférences selon vos besoins.</p>
`;
 