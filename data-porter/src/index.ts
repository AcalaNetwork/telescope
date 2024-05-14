import { cleanEnv, str } from 'envalid';
import assert from 'assert';
import dotenv from 'dotenv';

import { DbType, getDbConfig } from './consts';
import {
  pullDataFromDb,
  transformData,
  uploadToDune,
} from './actions';

dotenv.config();

const env = cleanEnv(process.env, {
  DB_TYPE: str({ choices: Object.values(DbType) }),
  DB_SCHEMA: str(),
  DB_TABLES: str(),
  DB_PASSWORD: str(),

  DUNE_API_KEY: str(),
  DUNE_TABLE_NAMES: str(),
});

const main = async () => {
  console.log('fetching data from db ...');

  const dbConfig = getDbConfig(env.DB_TYPE);
  const tables = env.DB_TABLES.split(',');
  assert(tables.length > 0, `invalid tables env: ${env.DB_TABLES}`);

  const tableNames = env.DUNE_TABLE_NAMES.split(',');
  assert(tables.length === tableNames.length, `db tables and dune table names count mismatch: ${tables.length} | ${tableNames.length}`);

  const clientConfig = {
    ...dbConfig,
    password: env.DB_PASSWORD,
  };

  const queryTarget = {
    schema: env.DB_SCHEMA,
    tables,
  };
  const dbData = await pullDataFromDb(clientConfig, queryTarget);
  console.log(`${dbData.length} tables fetched: ${dbData.map(({ table }) => table).join(', ') }`);

  for (const [idx, { schema, table, rows }] of dbData.entries()) {
    const tableName = tableNames[idx];
    console.log(`uploading data from [${schema}.${table}] with ${rows.length} rows to dune table [${tableName}] ...`);
    const data = transformData(rows);

    await uploadToDune({
      data,
      apiKey: env.DUNE_API_KEY,
      tableName,
      description: tableName,
    });
  }
};

main();
