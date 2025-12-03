declare namespace NodeJS {
  interface ProcessEnv {
    API_URL: string;
  }
}

declare var process: {
  env: NodeJS.ProcessEnv;
};