import { db } from './firebase';
import { Article } from '../models/article';

export async function createArticle(article: Article): Promise<Article | null> {
  try {
    const articleRef = await db.collection('articles').add(article);
    return { ...article, articleId: articleRef.id };
  } catch (error) {
    console.error('Error creating article:', error);
    return null;
  }
}

export async function getArticles(): Promise<Article[]> {
  try {
    const articlesSnapshot = await db.collection('articles').get();
    return articlesSnapshot.docs.map(doc => ({
      articleId: doc.id,
      ...doc.data()
    } as Article));
  } catch (error) {
    console.error('Error fetching articles:', error);
    return [];
  }
}