import { v4 as uuidv4 } from 'uuid';
import supabase from '../config/database'; 
import { 
  LoyaltyPoints, 
  PointSource, 
  PointTransactionType 
} from '../models/types';

interface LoyaltyTransaction {
  id: string;
  user_id: string;
  points: number;
  type: 'EARNED' | 'SPENT';
  source: PointSource;
  reference_id: string;
  created_at: Date;
  updated_at: Date;
}

export class LoyaltyService {
  static async earnPoints(
    userId: string, 
    points: number, 
    source: PointSource, 
    referenceId: string
  ): Promise<LoyaltyPoints> {
    try {
      // 1. Récupérer les points actuels
      const { data: loyaltyPoints, error: fetchError } = await supabase
        .from('loyalty_points')
        .select('pointsBalance, totalEarned')
        .eq('user_id', userId)
        .single();

      if (fetchError) throw fetchError;

      // 2. Mettre à jour les points
      const { data: updatedPoints, error: updateError } = await supabase
        .from('loyalty_points')
        .update({ 
          pointsBalance: (loyaltyPoints?.pointsBalance || 0) + points,
          totalEarned: (loyaltyPoints?.totalEarned || 0) + points,
          updated_at: new Date()
        })
        .eq('user_id', userId)
        .select()
        .single();

      if (updateError) throw updateError;

      // 3. Enregistrer la transaction
      await this.createPointTransaction(
        userId, 
        points, 
        'EARNED', 
        source, 
        referenceId
      );

      return updatedPoints;
    } catch (error) {
      console.error('[LoyaltyService] Error earning points:', error);
      throw error;
    }
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

  static async getCurrentPoints(userId: string): Promise<number> {
    try {
      const { data, error } = await supabase
        .from('loyalty_points')
        .select('pointsBalance')
        .eq('user_id', userId)
        .single();

      if (error) throw error;
      return data?.pointsBalance || 0;
    } catch (error) {
      console.error('[LoyaltyService] Error fetching points:', error);
      throw error;
    }
  }

  static async deductPoints(
    userId: string, 
    points: number,
    referenceId: string  // Ajout du paramètre obligatoire
  ): Promise<void> {
    try {
      const { data: loyalty, error: fetchError } = await supabase
        .from('loyalty_points')
        .select('pointsBalance')
        .eq('user_id', userId)
        .single();

      if (fetchError) throw fetchError;
      if (!loyalty) throw new Error('Loyalty record not found');
      if (loyalty.pointsBalance < points) throw new Error('Insufficient points');

      const { error: updateError } = await supabase
        .from('loyalty_points')
        .update({
          pointsBalance: loyalty.pointsBalance - points,
          updatedAt: new Date().toISOString()
        })
        .eq('user_id', userId);

      if (updateError) throw updateError;

      // Créer la transaction avec le referenceId
      const { error: transactionError } = await supabase
        .from('point_transactions')
        .insert({
          userId,
          points: -points,
          type: 'SPENT',
          source: 'ORDER',
          referenceId,  // Utilisation du referenceId passé
          createdAt: new Date().toISOString()
        });

      if (transactionError) throw transactionError;
    } catch (error) {
      console.error('[LoyaltyService] Error deducting points:', error);
      throw error;
    }
  }

  private static async createPointTransaction(
    userId: string, 
    points: number, 
    type: 'EARNED' | 'SPENT',
    source: PointSource, 
    referenceId: string
  ): Promise<void> {
    const transaction: LoyaltyTransaction = {
      id: uuidv4(),
      user_id: userId,
      points: points,
      type: type,
      source: source,
      reference_id: referenceId,
      created_at: new Date(),
      updated_at: new Date()
    };

    const { error } = await supabase
      .from('point_transactions')
      .insert([transaction]);

    if (error) throw error;
  }
}
