import { Client, ClientConfig } from 'pg';

export type Extended<T> = T & { [key: string]: any };

export interface RowBase {
  timestamp: string;
}

export type Row = Extended<RowBase>;

interface QueryTarget {
  schema: string,
  tables?: string[],
}

interface DbData <T = Row> {
  schema: string,
  table: string,
  rows: T[],
}

const getAllTables = async (client: Client, schema: string) => {
  console.log(`querying all tables under schema ${schema} ...`);

  const res = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = $1
  `, [schema]);

  return res.rows.map(row => row.table_name);
};

export const pullDataFromDb = async <T = Row>(
  clientConfig: ClientConfig,
  queryTarget: QueryTarget,
): Promise<DbData<T>[]> => {
  const { schema, tables } = queryTarget;
  const client = new Client(clientConfig);

  const res: DbData<T>[] = [];
  try {
    await client.connect();

    const tableNames = tables ?? await getAllTables(client, schema);

    for (const table of tableNames) {
      const { rows } = await client.query(`SELECT * FROM "${schema}"."${table}"`);
      res.push({
        schema,
        table,
        rows,
      });
    }

  } catch (err) {
    console.error('Error fetching data:', err);
  } finally {
    await client.end();
  }

  return res;
};
