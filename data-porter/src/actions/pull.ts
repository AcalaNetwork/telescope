import { Client, ClientConfig } from 'pg';

export type Extended<T> = T & { [key: string]: any };

export interface RowBase {
  timestamp: string;
}

export type Row = Extended<RowBase>;

interface DbTarget {
  schema: string;
  table: string;
}

interface DbData <T = Row> {
  schema: string,
  table: string,
  rows: T[],
}

export const pullDataFromDb = async <T = Row>(
  clientConfig: ClientConfig,
  dbTargets: DbTarget[],
): Promise<DbData<T>[]> => {
  const client = new Client(clientConfig);

  const res: DbData<T>[] = [];
  try {
    await client.connect();

    for (const { schema, table } of dbTargets) {
      const { rows } = await client.query(`SELECT * FROM "${schema}"."${table}"`);
      res.push({ schema, table, rows });
    }

  } catch (err) {
    console.error('Error fetching data:', err);
    throw err;
  } finally {
    await client.end();
  }

  return res;
};
