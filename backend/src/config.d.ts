interface Config {
  port: number;
  allowedOrigins: string | string[];
  email: {
    host: string | undefined;
    port: number;
    secure: boolean;
    user: string | undefined;
    password: string | undefined;
    fromName: string;
    fromAddress: string;
  };
  supabase: {
    url: string;
    key: string;
  };
}

declare const config: Config;
export { config };
