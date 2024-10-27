export const createMockRequest = (options = {}) => ({
  headers: {},
  body: {},
  params: {},
  ...options
});

export const createMockResponse = () => {
  const res: any = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  return res;
};
