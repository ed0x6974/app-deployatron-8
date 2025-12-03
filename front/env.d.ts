declare namespace NodeJS {
  interface ProcessEnv {
    PARCEL_API_URL: string;
  }
}

declare var process: {
  env: NodeJS.ProcessEnv;
};