import { cleanEnv, str } from 'envalid';
import dotenv from 'dotenv';

import { DbType } from '../consts';

dotenv.config();

export const env = cleanEnv(process.env, {
  DB_TYPE: str({ choices: Object.values(DbType) }),
  DB_TABLES: str(),
  DB_PASSWORD: str(),

  DUNE_API_KEY: str(),
  DUNE_TABLE_NAMES: str(),
});
