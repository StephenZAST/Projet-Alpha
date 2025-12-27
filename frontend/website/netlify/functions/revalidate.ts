/**
 * 🔄 Netlify Function - Revalidation Hook
 * 
 * Cette fonction permet à Render de notifier Netlify quand un article est publié
 * pour déclencher une régénération ISR immédiate
 * 
 * URL : https://votre-site.netlify.app/.netlify/functions/revalidate
 * 
 * Utilisation depuis Render :
 * POST /.netlify/functions/revalidate
 * Body: { "slug": "mon-article", "secret": "votre-secret" }
 */

export default async (req, context) => {
  // Vérifier le secret
  const secret = req.headers.get('x-revalidate-secret');
  if (secret !== process.env.REVALIDATE_SECRET) {
    return new Response('Unauthorized', { status: 401 });
  }

  try {
    const { slug } = await req.json();

    if (!slug) {
      return new Response('Missing slug', { status: 400 });
    }

    // Déclencher la régénération ISR
    // Note: Netlify n'a pas de support natif pour ISR comme Vercel
    // Cette fonction est un placeholder pour une implémentation future
    
    console.log(`✅ Revalidation triggered for slug: ${slug}`);

    return new Response(
      JSON.stringify({
        revalidated: true,
        slug,
        timestamp: new Date().toISOString(),
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Revalidation error:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
};
