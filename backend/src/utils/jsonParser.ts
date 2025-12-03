/**
 * 🔧 JSON Parser Utility - Extraction robuste de JSON depuis du texte
 */

export class JSONParser {
  /**
   * Extraire et parser du JSON depuis du texte
   * Essaie plusieurs approches pour extraire le JSON valide
   */
  static parseJSON(text: string): any {
    if (!text || typeof text !== 'string') {
      throw new Error('Invalid input: text must be a non-empty string');
    }

    console.log('[JSONParser] Tentative de parsing JSON...');

    // Approche 1 : Parser directement si c'est du JSON valide
    try {
      return JSON.parse(text);
    } catch (e) {
      console.log('[JSONParser] Approche 1 échouée: texte brut n\'est pas du JSON');
    }

    // Approche 2 : Chercher un objet JSON complet entre { }
    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        console.log('[JSONParser] Approche 2 réussie: JSON trouvé entre { }');
        return parsed;
      }
    } catch (e) {
      console.log('[JSONParser] Approche 2 échouée: JSON invalide entre { }');
    }

    // Approche 3 : Nettoyer le texte et réessayer
    try {
      const cleaned = this.cleanText(text);
      const jsonMatch = cleaned.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        console.log('[JSONParser] Approche 3 réussie: JSON trouvé après nettoyage');
        return parsed;
      }
    } catch (e) {
      console.log('[JSONParser] Approche 3 échouée');
    }

    // Approche 4 : Chercher les champs individuels et les reconstruire
    try {
      const extracted = this.extractFieldsManually(text);
      if (extracted && Object.keys(extracted).length >= 3) {
        console.log('[JSONParser] Approche 4 réussie: champs extraits manuellement');
        return extracted;
      }
    } catch (e) {
      console.log('[JSONParser] Approche 4 échouée:', e);
    }

    // Approche 5 : Chercher les balises markdown ```json et extraire
    try {
      const markdownMatch = text.match(/```json\s*([\s\S]*?)\s*```/);
      if (markdownMatch) {
        const parsed = JSON.parse(markdownMatch[1]);
        console.log('[JSONParser] Approche 5 réussie: JSON trouvé dans balises markdown');
        return parsed;
      }
    } catch (e) {
      console.log('[JSONParser] Approche 5 échouée');
    }

    throw new Error('Could not extract valid JSON from text');
  }

  /**
   * Extraire les champs manuellement depuis le texte
   */
  private static extractFieldsManually(text: string): any {
    const result: any = {};

    // Extraire le titre
    const titleMatch = text.match(/"title"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"/);
    if (titleMatch) {
      result.title = this.unescapeString(titleMatch[1]);
    }

    // Extraire l'excerpt
    const excerptMatch = text.match(/"excerpt"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"/);
    if (excerptMatch) {
      result.excerpt = this.unescapeString(excerptMatch[1]);
    }

    // Extraire le contenu (peut être très long)
    const contentMatch = text.match(/"content"\s*:\s*"((?:[^"\\]|\\.)*)"/);
    if (contentMatch) {
      result.content = this.unescapeString(contentMatch[1]);
    }

    // Extraire le reading_time
    const readingTimeMatch = text.match(/"reading_time"\s*:\s*(\d+)/);
    if (readingTimeMatch) {
      result.reading_time = parseInt(readingTimeMatch[1], 10);
    }

    return result;
  }

  /**
   * Nettoyer le texte pour améliorer le parsing
   */
  private static cleanText(text: string): string {
    // Supprimer les caractères de contrôle
    let cleaned = text.replace(/[\x00-\x1F\x7F]/g, ' ');

    // Supprimer les espaces multiples
    cleaned = cleaned.replace(/\s+/g, ' ');

    // Supprimer les balises markdown si présentes
    cleaned = cleaned.replace(/```json\s*/g, '');
    cleaned = cleaned.replace(/```\s*/g, '');

    return cleaned.trim();
  }

  /**
   * Unescape une chaîne JSON
   */
  private static unescapeString(str: string): string {
    return str
      .replace(/\\"/g, '"')
      .replace(/\\\\/g, '\\')
      .replace(/\\n/g, '\n')
      .replace(/\\r/g, '\r')
      .replace(/\\t/g, '\t')
      .replace(/\\b/g, '\b')
      .replace(/\\f/g, '\f');
  }

  /**
   * Valider que l'objet a les champs requis
   */
  static validate(obj: any, requiredFields: string[] = ['title', 'excerpt', 'content']): boolean {
    if (!obj || typeof obj !== 'object') {
      return false;
    }

    for (const field of requiredFields) {
      if (!obj[field] || (typeof obj[field] === 'string' && obj[field].trim() === '')) {
        console.log(`[JSONParser] Champ manquant ou vide: ${field}`);
        return false;
      }
    }

    return true;
  }
}
