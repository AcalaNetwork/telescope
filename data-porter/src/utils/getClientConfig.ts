import { ClientConfig } from 'pg';

import { env } from './parseEnv';
import { getDbConfig } from '../consts';

export const getClientConfig = (): ClientConfig => {
  const dbConfig = getDbConfig(env.DB_TYPE);
  return {
    ...dbConfig,
    password: env.DB_PASSWORD,
  };
};
