export interface PaginationParams {
  offset: number;
  limit: number;
  page?: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
  };
}
 
export const DEFAULT_PAGE_SIZE = 10;
export const MAX_PAGE_SIZE = 100;

export const DEFAULT_LIMIT = 10;
export const DEFAULT_OFFSET = 0;

export const validatePaginationParams = (query: any): PaginationParams => {
  const page = Math.max(1, parseInt(query.page as string, 10) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit as string, 10) || DEFAULT_LIMIT));
  const offset = (page - 1) * limit;

  return {
    offset,
    limit,
    page
  };
};
  
export function calculatePagination(total: number, page: number, limit: number) {
  const totalPages = Math.ceil(total / limit);
  
  return {
    total,
    page,
    limit,
    totalPages,
    hasNextPage: page < totalPages,
    hasPreviousPage: page > 1
  };
}

export function getPaginationRange(page: number, limit: number): [number, number] {
  const from = (page - 1) * limit;
  const to = from + limit - 1;
  return [from, to];
}