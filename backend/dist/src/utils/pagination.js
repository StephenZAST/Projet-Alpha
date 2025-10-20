"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validatePaginationParams = exports.DEFAULT_OFFSET = exports.DEFAULT_LIMIT = exports.MAX_PAGE_SIZE = exports.DEFAULT_PAGE_SIZE = void 0;
exports.calculatePagination = calculatePagination;
exports.getPaginationRange = getPaginationRange;
exports.DEFAULT_PAGE_SIZE = 10;
exports.MAX_PAGE_SIZE = 100;
exports.DEFAULT_LIMIT = 10;
exports.DEFAULT_OFFSET = 0;
const validatePaginationParams = (query) => {
    const page = Math.max(1, parseInt(query.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(query.limit, 10) || exports.DEFAULT_LIMIT));
    const offset = (page - 1) * limit;
    return {
        offset,
        limit,
        page
    };
};
exports.validatePaginationParams = validatePaginationParams;
function calculatePagination(total, page, limit) {
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
function getPaginationRange(page, limit) {
    const from = (page - 1) * limit;
    const to = from + limit - 1;
    return [from, to];
}
