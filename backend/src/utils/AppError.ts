export default class AppError extends Error {
  public statusCode: number;
  public errorCode: string;
  public errors?: any[];

  constructor(statusCode: number, message: string, errorCode: string, errors?: any[]) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.errors = errors;
  }
}
