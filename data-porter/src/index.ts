import {
  env,
  getClientConfig,
  getQueryTarget,
} from './utils';
import {
  pullDataFromDb,
  transformData,
  uploadToDune,
} from './actions';

const main = async () => {
  console.log('constructing query params ...');
  const { dbTargets, tableNames } = getQueryTarget();
  const clientConfig = getClientConfig();

  console.log('fetching data from db ...');
  const dbData = await pullDataFromDb(clientConfig, dbTargets);
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
