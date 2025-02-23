declare module 'google-trends-api' {
  interface TrendsApiOptions {
    keyword: string;
    startTime?: Date;
    endTime?: Date;
    geo?: string;
    hl?: string;
    category?: number;
  }

  interface TrendsResult {
    default: {
      timelineData: Array<{
        time: string;
        formattedTime: string;
        formattedValue: string;
        value: number[];
      }>;
    };
  }

  function interestOverTime(options: TrendsApiOptions): Promise<string>;
  function relatedQueries(options: TrendsApiOptions): Promise<string>;
  function dailyTrends(options: { geo: string; hl?: string }): Promise<string>;

  export {
    interestOverTime,
    relatedQueries,
    dailyTrends,
    TrendsApiOptions,
    TrendsResult
  };
}
