import { v4 as uuidv4 } from 'uuid';
import { PrismaClient } from '@prisma/client';
import { LoyaltyPoints, PointSource, PointTransactionType } from '../models/types';

const prisma = new PrismaClient();

export class LoyaltyService {
  /**
   * 💰 Attribue les points de fidélité basés sur le prix effectif de la commande
   * Utilise le prix manuel s'il existe, sinon le prix originel
   * 
   * ✅ À UTILISER lors de la création d'une commande pour attribuer les points
   * 
   * @param userId - ID de l'utilisateur
   * @param order - La commande complète avec relations (doit inclure pricing)
   * @param source - Source des points (ORDER, REFERRAL, etc.)
   * @returns Les points de fidélité mis à jour
   */
  static async earnPointsFromOrder(
    userId: string,
    order: any,
    source: PointSource = 'ORDER'
  ): Promise<LoyaltyPoints> {
    try {
      // Importer la fonction utilitaire
      const { getEffectiveOrderTotal } = require('../controllers/order.controller/shared');
      
      // Récupérer le prix effectif (manuel ou originel)
      const effectiveTotal = getEffectiveOrderTotal(order);
      
      // Calculer les points (ex: 1 point par 100 FCFA)
      const pointsMultiplier = Number(process.env.POINTS_MULTIPLIER || 0.01);
      const points = Math.floor(effectiveTotal * pointsMultiplier);
      
      console.log(
        `[LoyaltyService] Earning points from order:
        Order ID: ${order.id}
        Effective Total: ${effectiveTotal}
        Points Multiplier: ${pointsMultiplier}
        Points Earned: ${points}`
      );
      
      // Attribuer les points
      return await this.earnPoints(userId, points, source, order.id);
    } catch (error) {
      console.error('[LoyaltyService] Error earning points from order:', error);
      throw error;
    }
  }
  static async earnPoints(
    userId: string, 
    points: number, 
    source: PointSource, 
    referenceId: string
  ): Promise<LoyaltyPoints> {
    try {
      const result = await prisma.$transaction(async (tx) => {
        const loyaltyPoints = await tx.loyalty_points.findUnique({
          where: { userId: userId }
        });

        const currentBalance = loyaltyPoints?.pointsBalance || 0;
        const currentTotal = loyaltyPoints?.totalEarned || 0;

        const updatedPoints = await tx.loyalty_points.update({
          where: { userId: userId },
          data: {
            pointsBalance: { increment: points },
            totalEarned: { increment: points },
            updatedAt: new Date()
          }
        });

        await tx.point_transactions.create({
          data: {
            id: uuidv4(),
            userId,
            points,
            type: 'EARNED',
            source,
            referenceId,
            createdAt: new Date()
          }
        });

        // Mise à jour du solde de points (remplace le trigger SQL)
  // Suppression de l'update redondant du solde de points

        // Vérification du solde négatif
        const checkLoyalty = await tx.loyalty_points.findUnique({ where: { userId } });
        if (checkLoyalty && (checkLoyalty.pointsBalance ?? 0) < 0) {
          throw new Error('Le solde de points ne peut pas être négatif');
        }

        return {
          id: updatedPoints.id,
          user_id: updatedPoints.userId || userId, // Assure une valeur non-null
          pointsBalance: updatedPoints.pointsBalance || 0,
          totalEarned: updatedPoints.totalEarned || 0,
          createdAt: updatedPoints.createdAt || new Date(),
          updatedAt: updatedPoints.updatedAt || new Date()
        };
      });

      return result;
    } catch (error) {
      console.error('[LoyaltyService] Error earning points:', error);
      throw error;
    }
  }

  static async spendPoints(
    userId: string, 
    points: number, 
    source: PointSource, 
    referenceId: string
  ): Promise<LoyaltyPoints> {
    try {
      return await prisma.$transaction(async (tx) => {
        const loyaltyPoints = await tx.loyalty_points.findUnique({
          where: { userId: userId }
        });

        const currentBalance = loyaltyPoints?.pointsBalance ?? 0;
        if (!loyaltyPoints || currentBalance < points) {
          throw new Error('Insufficient points balance');
        }

        const updatedPoints = await tx.loyalty_points.update({
          where: { userId: userId },
          data: {
            pointsBalance: { decrement: points },
            updatedAt: new Date()
          }
        });

        await tx.point_transactions.create({
          data: {
            id: uuidv4(),
            userId,
            points: -points,
            type: 'SPENT',
            source,
            referenceId,
            createdAt: new Date()
          }
        });

        // Mise à jour du solde de points (remplace le trigger SQL)
  // Suppression de l'update redondant du solde de points

        // Vérification du solde négatif
        const checkLoyalty = await tx.loyalty_points.findUnique({ where: { userId } });
        if (checkLoyalty && (checkLoyalty.pointsBalance ?? 0) < 0) {
          throw new Error('Le solde de points ne peut pas être négatif');
        }

        // Transformer en type non-null
        return {
          id: updatedPoints.id,
          user_id: updatedPoints.userId ?? userId,
          pointsBalance: updatedPoints.pointsBalance ?? 0,
          totalEarned: updatedPoints.totalEarned ?? 0,
          createdAt: updatedPoints.createdAt ?? new Date(),
          updatedAt: updatedPoints.updatedAt ?? new Date()
        };
      });
    } catch (error) {
      console.error('[LoyaltyService] Error spending points:', error);
      throw error;
    }
  }

  static async getPointsBalance(userId: string): Promise<LoyaltyPoints | null> {
    try {
      const points = await prisma.loyalty_points.findUnique({
        where: { userId: userId }
      });

      if (!points) return null;

      return {
        id: points.id,
        user_id: points.userId || userId,
        pointsBalance: points.pointsBalance || 0,
        totalEarned: points.totalEarned || 0,
        createdAt: points.createdAt || new Date(),
        updatedAt: points.updatedAt || new Date()
      };
    } catch (error) {
      console.error('[LoyaltyService] Error getting points balance:', error);
      throw error;
    }
  }

  static async getCurrentPoints(userId: string): Promise<number> {
    try {
      const points = await prisma.loyalty_points.findUnique({
        where: { userId: userId },
        select: { pointsBalance: true }
      });
      return points?.pointsBalance || 0;
    } catch (error) {
      console.error('[LoyaltyService] Error fetching points:', error);
      throw error;
    }
  }

  static async deductPoints(
    userId: string, 
    points: number,
    referenceId: string
  ): Promise<void> {
    try {
      await prisma.$transaction(async (tx) => {
        const loyalty = await tx.loyalty_points.findUnique({
          where: { userId: userId }
        });

        // Vérifier explicitement la valeur de pointsBalance
        const currentBalance = loyalty?.pointsBalance ?? 0;
        if (!loyalty || currentBalance < points) {
          throw new Error('Insufficient points');
        }

        await tx.loyalty_points.update({
          where: { userId: userId },
          data: {
            pointsBalance: currentBalance - points,
            updatedAt: new Date()
          }
        });

        await tx.point_transactions.create({
          data: {
            id: uuidv4(),
            userId,
            points: -points,
            type: 'SPENT',
            source: 'ORDER',
            referenceId,
            createdAt: new Date()
          }
        });

        // Mise à jour du solde de points (remplace le trigger SQL)
        await tx.loyalty_points.update({
          where: { userId: userId },
          data: {
            pointsBalance: { decrement: points },
            updatedAt: new Date()
          }
        });

        // Vérification du solde négatif
        const checkLoyalty = await tx.loyalty_points.findUnique({ where: { userId } });
        if (checkLoyalty && (checkLoyalty.pointsBalance ?? 0) < 0) {
          throw new Error('Le solde de points ne peut pas être négatif');
        }
      });
    } catch (error) {
      console.error('[LoyaltyService] Error deducting points:', error);
      throw error;
    }
  }
}
