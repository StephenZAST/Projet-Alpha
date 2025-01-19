import { Order } from '../models/types';

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
