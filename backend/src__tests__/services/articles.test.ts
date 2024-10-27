import { createArticle, getArticles, updateArticle, deleteArticle } from '../services/articles';
import { db } from '../services/firebase';
import { Article } from '../models/article';
import { MainService, PriceType } from '../models/order';

jest.mock('../../services/firebase');

describe('Article Services', () => {
  const mockArticle: Article = {
    articleId: '123',
    articleName: 'Test Article',
    articleCategory: 'Chemisier',
    prices: {
      [MainService.WASH_AND_IRON]: {
        [PriceType.STANDARD]: 500,
        [PriceType.BASIC]: 300
      }
    },
    availableServices: [MainService.WASH_AND_IRON],
    availableAdditionalServices: []
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('createArticle creates and returns article', async () => {
    const addMock = jest.fn().mockResolvedValue({ id: '123' });
    (db.collection as jest.Mock).mockReturnValue({ add: addMock });

    const result = await createArticle(mockArticle);
    expect(result).toEqual(mockArticle);
    expect(addMock).toHaveBeenCalledWith(mockArticle);
  });

  test('getArticles returns array of articles', async () => {
    const getMock = jest.fn().mockResolvedValue({
      docs: [{ id: '123', data: () => mockArticle }]
    });
    (db.collection as jest.Mock).mockReturnValue({ get: getMock });

    const result = await getArticles();
    expect(result).toEqual([mockArticle]);
  });
});
