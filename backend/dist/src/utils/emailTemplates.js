"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.welcomeNotificationTemplate = exports.notificationEmailTemplate = exports.orderStatusUpdateTemplate = exports.orderConfirmationTemplate = void 0;
const orderConfirmationTemplate = (order) => {
    var _a;
    return `
  <h1>Confirmation de commande - Alpha Laundry</h1>
  <p>Votre commande #${order.id} a été reçue avec succès.</p>
  <h2>Détails de la commande :</h2>
  <ul>
    ${(_a = order.items) === null || _a === void 0 ? void 0 : _a.map(item => {
        var _a, _b;
        return `
      <li>${item.quantity} x ${(_b = (_a = item.article) === null || _a === void 0 ? void 0 : _a.name) !== null && _b !== void 0 ? _b : 'Article inconnu'}</li>
    `;
    }).join('')}
  </ul>
  <p>Total: ${order.totalAmount}€</p>
  <p>Statut: ${order.status}</p>
`;
};
exports.orderConfirmationTemplate = orderConfirmationTemplate;
const orderStatusUpdateTemplate = (order, newStatus) => `
  <h1>Mise à jour de votre commande - Alpha Laundry</h1>
  <p>Le statut de votre commande #${order.id} a été mis à jour.</p>
  <p>Nouveau statut: ${newStatus}</p>
`;
exports.orderStatusUpdateTemplate = orderStatusUpdateTemplate;
const notificationEmailTemplate = (title, message, type) => `
  <h1>${title}</h1>
  <p>${message}</p>
  <div style="margin-top: 20px; font-size: 12px; color: #666;">
    <p>Type de notification: ${type}</p>
    <p>Pour gérer vos préférences de notifications, connectez-vous à votre compte.</p>
  </div>
`;
exports.notificationEmailTemplate = notificationEmailTemplate;
const welcomeNotificationTemplate = (firstName) => `
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
exports.welcomeNotificationTemplate = welcomeNotificationTemplate;
