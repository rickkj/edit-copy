export const RESOLVE_CONFIG = {
  HOST: '127.0.0.1',
  PORT: 56002,
  URL: 'http://127.0.0.1:56002/',
  TIMEOUTS: {
    PING: 10,
    GET_INFO: 10,
    GET_TIMELINE: 10,
    APPLY: 60,
  }
} as const;
