/**
 * 🔔 Notification Channels Service - Gestion des canaux de notification
 * 
 * Ce service gère l'envoi des notifications via différents canaux:
 * - PUSH: Firebase Cloud Messaging
 * - EMAIL: Service email (Nodemailer/SendGrid)
 * - IN_APP: Notifications en base de données
 */

import { PrismaClient } from '@prisma/client';
import { NotificationChannel } from '../types/notification.types';

const prisma = new PrismaClient();

export class NotificationChannels {
  
  /**
   * Envoyer une notification PUSH via Firebase Cloud Messaging
   * 
   * @param userId - ID de l'utilisateur
   * @param title - Titre de la notification
   * @param message - Message de la notification
   * @param data - Données additionnelles
   */
  static async sendPush(
    userId: string,
    title: string,
    message: string,
    data: Record<string, any> = {}
  ): Promise<void> {
    try {
      // TODO: Implémenter avec Firebase Admin SDK
      // Pour maintenant: log seulement
      console.log(`📱 PUSH NOTIFICATION`);
      console.log(`   User ID: ${userId}`);
      console.log(`   Title: ${title}`);
      console.log(`   Message: ${message}`);
      console.log(`   Data: ${JSON.stringify(data)}`);
      console.log(`   Status: ⏳ Pending Firebase implementation`);
      
      // Exemple d'implémentation future:
      // const admin = require('firebase-admin');
      // const message = admin.messaging.Message({
      //   notification: { title, body: message },
      //   data,
      //   token: userFcmToken
      // });
      // await admin.messaging().send(message);
    } catch (error) {
      console.error('❌ Error sending push notification:', error);
      // Ne pas relancer l'erreur pour ne pas bloquer les autres canaux
    }
  }

  /**
   * Envoyer une notification EMAIL
   * 
   * @param userId - ID de l'utilisateur
   * @param title - Titre de l'email
   * @param message - Corps du message
   * @param htmlContent - Contenu HTML optionnel
   */
  static async sendEmail(
    userId: string,
    title: string,
    message: string,
    htmlContent?: string
  ): Promise<void> {
    try {
      // Récupérer l'email de l'utilisateur
      const user = await prisma.users.findUnique({
        where: { id: userId },
        select: { email: true, first_name: true }
      });

      if (!user) {
        console.warn(`⚠️ User not found for email notification: ${userId}`);
        return;
      }

      // TODO: Implémenter avec Nodemailer ou SendGrid
      // Pour maintenant: log seulement
      console.log(`📧 EMAIL NOTIFICATION`);
      console.log(`   To: ${user.email}`);
      console.log(`   Subject: ${title}`);
      console.log(`   Message: ${message}`);
      console.log(`   Status: ⏳ Pending email service implementation`);

      // Exemple d'implémentation future:
      // const nodemailer = require('nodemailer');
      // const transporter = nodemailer.createTransport({...});
      // await transporter.sendMail({
      //   from: process.env.EMAIL_FROM,
      //   to: user.email,
      //   subject: title,
      //   text: message,
      //   html: htmlContent || message
      // });
    } catch (error) {
      console.error('❌ Error sending email notification:', error);
      // Ne pas relancer l'erreur pour ne pas bloquer les autres canaux
    }
  }

  /**
   * Créer une notification IN_APP (en base de données)
   * 
   * @param userId - ID de l'utilisateur
   * @param type - Type de notification
   * @param title - Titre de la notification
   * @param message - Message de la notification
   * @param data - Données additionnelles
   */
  static async createInApp(
    userId: string,
    type: string,
    title: string,
    message: string,
    data: Record<string, any> = {}
  ): Promise<string> {
    try {
      const notification = await prisma.notifications.create({
        data: {
          userId,
          type,
          message,
          data: {
            title,
            ...data
          },
          read: false
        }
      });

      console.log(`💬 IN_APP NOTIFICATION CREATED`);
      console.log(`   User ID: ${userId}`);
      console.log(`   Type: ${type}`);
      console.log(`   Title: ${title}`);
      console.log(`   Notification ID: ${notification.id}`);

      return notification.id;
    } catch (error) {
      console.error('❌ Error creating in-app notification:', error);
      throw error;
    }
  }

  /**
   * Envoyer une notification via plusieurs canaux
   * 
   * @param userId - ID de l'utilisateur
   * @param channels - Canaux à utiliser
   * @param title - Titre
   * @param message - Message
   * @param data - Données additionnelles
   */
  static async sendViaChannels(
    userId: string,
    channels: NotificationChannel[],
    title: string,
    message: string,
    data: Record<string, any> = {}
  ): Promise<void> {
    try {
      console.log(`\n🔔 SENDING NOTIFICATION VIA ${channels.length} CHANNEL(S)`);
      console.log(`   User: ${userId}`);
      console.log(`   Channels: ${channels.join(', ')}`);
      console.log(`   Title: ${title}`);
      console.log(`   Message: ${message}\n`);

      // Envoyer via tous les canaux en parallèle
      const promises: Promise<any>[] = [];

      if (channels.includes('PUSH')) {
        promises.push(this.sendPush(userId, title, message, data));
      }

      if (channels.includes('EMAIL')) {
        promises.push(this.sendEmail(userId, title, message));
      }

      if (channels.includes('IN_APP')) {
        promises.push(this.createInApp(userId, 'NOTIFICATION', title, message, data));
      }

      // Attendre que tous les canaux soient traités
      await Promise.allSettled(promises);

      console.log(`✅ Notification sent via all channels\n`);
    } catch (error) {
      console.error('❌ Error sending notification via channels:', error);
      throw error;
    }
  }

  /**
   * Envoyer une notification à tous les utilisateurs d'un rôle spécifique
   * 
   * @param role - Rôle des utilisateurs
   * @param channels - Canaux à utiliser
   * @param title - Titre
   * @param message - Message
   * @param data - Données additionnelles
   */
  static async sendToRole(
    role: string,
    channels: NotificationChannel[],
    title: string,
    message: string,
    data: Record<string, any> = {}
  ): Promise<number> {
    try {
      // Récupérer tous les utilisateurs du rôle
      const users = await prisma.users.findMany({
        where: { role: role as any },
        select: { id: true }
      });

      if (users.length === 0) {
        console.warn(`⚠️ No users found with role: ${role}`);
        return 0;
      }

      console.log(`\n🔔 SENDING NOTIFICATION TO ${users.length} USER(S) WITH ROLE: ${role}`);
      console.log(`   Channels: ${channels.join(', ')}`);
      console.log(`   Title: ${title}\n`);

      // Envoyer à tous les utilisateurs en parallèle
      const promises = users.map(user =>
        this.sendViaChannels(user.id, channels, title, message, data)
      );

      await Promise.allSettled(promises);

      console.log(`✅ Notification sent to ${users.length} users with role: ${role}\n`);

      return users.length;
    } catch (error) {
      console.error('❌ Error sending notification to role:', error);
      throw error;
    }
  }

  /**
   * Vérifier les préférences de notification de l'utilisateur
   * 
   * @param userId - ID de l'utilisateur
   * @param channel - Canal à vérifier
   * @returns true si le canal est activé
   */
  static async isChannelEnabled(
    userId: string,
    channel: NotificationChannel
  ): Promise<boolean> {
    try {
      const preferences = await prisma.notification_preferences.findFirst({
        where: { userId }
      });

      if (!preferences) {
        // Par défaut, tous les canaux sont activés
        return true;
      }

      // Vérifier le canal spécifique (champs existants en BD)
      switch (channel) {
        case 'PUSH':
          return preferences.push ?? true;
        case 'EMAIL':
          return preferences.email ?? true;
        case 'IN_APP':
          return true; // IN_APP est toujours activé
        default:
          return true;
      }
    } catch (error) {
      console.error('❌ Error checking channel preference:', error);
      return true; // Par défaut, autoriser l'envoi
    }
  }

  /**
   * Envoyer une notification en respectant les préférences utilisateur
   * 
   * @param userId - ID de l'utilisateur
   * @param channels - Canaux à utiliser
   * @param title - Titre
   * @param message - Message
   * @param data - Données additionnelles
   * @param forceSend - Forcer l'envoi (pour notifications critiques)
   */
  static async sendWithPreferences(
    userId: string,
    channels: NotificationChannel[],
    title: string,
    message: string,
    data: Record<string, any> = {},
    forceSend: boolean = false
  ): Promise<void> {
    try {
      // Si forceSend est true, envoyer directement (pour notifications critiques)
      if (forceSend) {
        await this.sendViaChannels(userId, channels, title, message, data);
        return;
      }

      // Filtrer les canaux en fonction des préférences
      const enabledChannels: NotificationChannel[] = [];
      for (const channel of channels) {
        const enabled = await this.isChannelEnabled(userId, channel);
        if (enabled) {
          enabledChannels.push(channel);
        }
      }

      if (enabledChannels.length === 0) {
        console.log(`⏭️ No enabled channels for user ${userId}`);
        return;
      }

      // Envoyer via les canaux activés
      await this.sendViaChannels(userId, enabledChannels, title, message, data);
    } catch (error) {
      console.error('❌ Error sending notification with preferences:', error);
      throw error;
    }
  }
}
