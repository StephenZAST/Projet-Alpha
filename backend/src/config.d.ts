interface Config {
  port: number;
  allowedOrigins: string | string[];
}

declare const config: Config;
export { config };
