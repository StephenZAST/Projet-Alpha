import { v4 as uuidv4 } from 'uuid';
import { PrismaClient } from '@prisma/client';
import { LoyaltyPoints, PointSource, PointTransactionType } from '../models/types';

const prisma = new PrismaClient();

export class LoyaltyService {
  static async earnPoints(
    userId: string, 
    points: number, 
    source: PointSource, 
    referenceId: string
  ): Promise<LoyaltyPoints> {
    try {
      const result = await prisma.$transaction(async (tx) => {
        const loyaltyPoints = await tx.loyalty_points.findUnique({
          where: { user_id: userId }
        });

        const currentBalance = loyaltyPoints?.pointsBalance || 0;
        const currentTotal = loyaltyPoints?.totalEarned || 0;

        const updatedPoints = await tx.loyalty_points.update({
          where: { user_id: userId },
          data: {
            pointsBalance: currentBalance + points,
            totalEarned: currentTotal + points,
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

        return {
          id: updatedPoints.id,
          user_id: updatedPoints.user_id || userId, // Assure une valeur non-null
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
          where: { user_id: userId }
        });

        const currentBalance = loyaltyPoints?.pointsBalance ?? 0;
        if (!loyaltyPoints || currentBalance < points) {
          throw new Error('Insufficient points balance');
        }

        const updatedPoints = await tx.loyalty_points.update({
          where: { user_id: userId },
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
            source,
            referenceId,
            createdAt: new Date()
          }
        });

        // Transformer en type non-null
        return {
          id: updatedPoints.id,
          user_id: updatedPoints.user_id ?? userId,
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
        where: { user_id: userId }
      });

      if (!points) return null;

      return {
        id: points.id,
        user_id: points.user_id || userId,
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
        where: { user_id: userId },
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
          where: { user_id: userId }
        });

        // Vérifier explicitement la valeur de pointsBalance
        const currentBalance = loyalty?.pointsBalance ?? 0;
        if (!loyalty || currentBalance < points) {
          throw new Error('Insufficient points');
        }

        await tx.loyalty_points.update({
          where: { user_id: userId },
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
      });
    } catch (error) {
      console.error('[LoyaltyService] Error deducting points:', error);
      throw error;
    }
  }
}
