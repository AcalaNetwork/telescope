import assert from 'assert';

import { env } from './parseEnv';

export const getQueryTarget = () => {
  const dbTargets = env.DB_TABLES
    .trim()
    .split(',')
    .map(pair => {
      const [schema, table] = pair.split('.');
      if (!schema || !table) {
        throw new Error(`invalid schema.table: ${pair}`);
      }
      return {
        schema: schema.trim(),
        table: table.trim(),
      };
    });

  const tableNames = env.DUNE_TABLE_NAMES.split(',');
  assert(dbTargets.length === tableNames.length,
    `db tables and dune table names count mismatch: ${dbTargets.length} | ${tableNames.length}`);

  return { dbTargets, tableNames };
};
