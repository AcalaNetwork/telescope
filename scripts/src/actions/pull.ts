import { Client, ClientConfig } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

export interface Tx {
  timestamp: string;
  pool_id: string;
  amount: string;
  from: string;
  type: string;
}

export interface Row extends Tx {
  [key: string]: any;
}

interface QueryTarget {
  schema: string,
  tables: string[],
  filenames: string[],
}
type QueryParams = ClientConfig & QueryTarget;

const getAllTables = async (client: Client, schema: string) => {
  console.log(`querying all tables under schema ${schema} ...`);

  const res = await client.query(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = $1
    `, [schema]);

  return res.rows.map(row => row.table_name);
};

export const pullDataFromDb = async ({
  host,
  port,
  database,
  user,
  password,
  schema,
  tables,
}: QueryParams): Promise<Row[][]> => {
  const client = new Client({
    host: host,
    port: port,
    database: database,
    user: user,
    password: password,
  });

  const res = [];
  try {
    await client.connect();

    const tableNames = tables ?? await getAllTables(client, schema);

    for (const table of tableNames) {
      const data = await client.query(`SELECT * FROM "${schema}"."${table}"`);
      res.push(data.rows);
    }

  } catch (err) {
    console.error('Error fetching data:', err);
  } finally {
    await client.end();
  }

  return res;
};
