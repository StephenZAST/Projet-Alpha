import supabase from '../config/database';
import { PointTransaction, PointTransactionType, PointSource, LoyaltyPoints } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

export class LoyaltyService {
  static async earnPoints(userId: string, points: number, source: PointSource, referenceId: string): Promise<LoyaltyPoints> {
    const { data: loyaltyPoints } = await supabase
      .from('loyalty_points')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (!loyaltyPoints) {
      throw new Error('Loyalty points profile not found');
    }

    const newPointsBalance = loyaltyPoints.pointsBalance + points;

    const { data, error } = await supabase
      .from('loyalty_points')
      .update({ pointsBalance: newPointsBalance, totalEarned: loyaltyPoints.totalEarned + points })
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;

    // Enregistrer la transaction
    await this.createPointTransaction(userId, points, 'EARNED', source, referenceId);

    return data;
  }

  static async spendPoints(userId: string, points: number, source: PointSource, referenceId: string): Promise<LoyaltyPoints> {
    const { data: loyaltyPoints } = await supabase
      .from('loyalty_points')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (!loyaltyPoints) {
      throw new Error('Loyalty points profile not found');
    }

    if (loyaltyPoints.pointsBalance < points) {
      throw new Error('Insufficient points balance');
    }

    const newPointsBalance = loyaltyPoints.pointsBalance - points;

    const { data, error } = await supabase
      .from('loyalty_points')
      .update({ pointsBalance: newPointsBalance })
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;

    // Enregistrer la transaction
    await this.createPointTransaction(userId, points, 'SPENT', source, referenceId);

    return data;
  }

  static async getPointsBalance(userId: string): Promise<LoyaltyPoints> {
    const { data, error } = await supabase
      .from('loyalty_points')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error) throw error;

    return data;
  }

  private static async createPointTransaction(userId: string, points: number, type: PointTransactionType, source: PointSource, referenceId: string): Promise<void> {
    const newPointTransaction: PointTransaction = {
      id: uuidv4(),
      userId: userId,
      points: points,
      type: type,
      source: source,
      referenceId: referenceId,
      createdAt: new Date()
    };

    const { error } = await supabase
      .from('point_transactions')
      .insert([newPointTransaction]);

    if (error) throw error;
  }
}
