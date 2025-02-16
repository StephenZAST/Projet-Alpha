import supabase from '../config/database';
import { Offer, CreateOfferDTO } from '../models/types';

export class OfferService {
  static async createOffer(offerData: CreateOfferDTO): Promise<Offer> {
    const { articleIds, ...offerDetails } = offerData;

    // Créer l'offre
    const { data: offer, error } = await supabase
      .from('offers')
      .insert([{
        ...offerDetails,
        created_at: new Date(),
        updated_at: new Date()
      }])
      .select()
      .single();

    if (error) throw error;

    // Associer les articles si fournis
    if (articleIds?.length) {
      const offerArticles = articleIds.map(articleId => ({
        offer_id: offer.id,
        article_id: articleId
      }));

      const { error: linkError } = await supabase
        .from('offer_articles')
        .insert(offerArticles);

      if (linkError) throw linkError;
    }

    return offer;
  }
 
  static async getAvailableOffers(userId: string): Promise<Offer[]> {
    const { data, error } = await supabase
      .from('offers')
      .select(`
        *,
        articles:offer_articles(articles(*))
      `)
      .eq('is_active', true)
      .lte('startDate', new Date().toISOString())
      .gte('endDate', new Date().toISOString());

    if (error) throw error;
    return data;
  }

  static async getOfferById(offerId: string): Promise<Offer> {
    const { data, error } = await supabase
      .from('offers')
      .select(`
        *,
        articles:offer_articles(articles(*))
      `)
      .eq('id', offerId)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Offer not found');
    
    return data;
  }

  static async updateOffer(offerId: string, updateData: Partial<CreateOfferDTO>): Promise<Offer> {
    const { articleIds, ...offerDetails } = updateData;

    const { data, error } = await supabase
      .from('offers')
      .update({
        ...offerDetails,
        updated_at: new Date()
      })
      .eq('id', offerId)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new Error('Offer not found');

    // Mettre à jour les articles si fournis
    if (articleIds) {
      await supabase
        .from('offer_articles')
        .delete()
        .eq('offer_id', offerId);

      if (articleIds.length > 0) {
        const offerArticles = articleIds.map(articleId => ({
          offer_id: offerId,
          article_id: articleId
        }));

        const { error: linkError } = await supabase
          .from('offer_articles')
          .insert(offerArticles);

        if (linkError) throw linkError;
      }
    }

    return data;
  }

  static async deleteOffer(offerId: string): Promise<void> {
    const { error } = await supabase
      .from('offers')
      .delete()
      .eq('id', offerId);

    if (error) throw error;
  }

  static async toggleOfferStatus(offerId: string, isActive: boolean): Promise<Offer> {
    const { data, error } = await supabase
      .from('offers')
      .update({
        is_active: isActive,
        updated_at: new Date()
      })
      .eq('id', offerId)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new Error('Offer not found');

    return data;
  }
}
