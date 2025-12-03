/**
 * Script pour vérifier les modèles Gemini disponibles
 * Utilise l'API Google Generative AI pour lister les modèles
 */

import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const API_KEY = process.env.GOOGLE_AI_API_KEY;

if (!API_KEY) {
  console.error('❌ GOOGLE_AI_API_KEY not configured');
  process.exit(1);
}

async function checkAvailableModels() {
  try {
    console.log('🔍 Vérification des modèles Gemini disponibles...\n');

    const response = await axios.get(
      'https://generativelanguage.googleapis.com/v1beta/models',
      {
        headers: {
          'x-goog-api-key': API_KEY
        }
      }
    );

    const models = response.data.models || [];

    console.log(`✅ ${models.length} modèles trouvés:\n`);

    // Filtrer et afficher les modèles pertinents
    const relevantModels = models.filter((model: any) => 
      model.name.includes('gemini') && 
      model.supportedGenerationMethods?.includes('generateContent')
    );

    relevantModels.forEach((model: any, index: number) => {
      const modelName = model.name.split('/').pop();
      const displayName = model.displayName || modelName;
      const version = model.version || 'unknown';
      
      console.log(`${index + 1}. ${displayName}`);
      console.log(`   Nom: ${modelName}`);
      console.log(`   Version: ${version}`);
      console.log(`   Méthodes: ${model.supportedGenerationMethods?.join(', ')}`);
      console.log(`   Tokens entrée: ${model.inputTokenLimit || 'N/A'}`);
      console.log(`   Tokens sortie: ${model.outputTokenLimit || 'N/A'}`);
      console.log('');
    });

    // Recommandation
    console.log('\n📋 Recommandations:');
    console.log('- Pour la génération rapide: gemini-2.0-flash');
    console.log('- Pour la qualité: gemini-2.0-pro');
    console.log('- Pour les tâches légères: gemini-1.5-flash');
    console.log('- Pour les tâches complexes: gemini-1.5-pro');

  } catch (error: any) {
    console.error('❌ Erreur lors de la vérification des modèles:');
    if (error.response?.data?.error) {
      console.error(error.response.data.error);
    } else {
      console.error(error.message);
    }
    process.exit(1);
  }
}

checkAvailableModels();
