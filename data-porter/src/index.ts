import { cleanEnv, str } from 'envalid';
import dotenv from 'dotenv';

import { DB_CONFIG_DEV } from './consts';
import {
  pullDataFromDb,
  transformCSV,
  uploadToDune,
} from './actions';

dotenv.config();

const env = cleanEnv(process.env, {
  PASSWORD_DEV: str(),
  API_KEY: str(),
  DB_SCHEMA: str(),
});

const main = async () => {
  console.log('fetching data from db ...');

  const [rawData] = await pullDataFromDb({
    ...DB_CONFIG_DEV,
    schema: env.DB_SCHEMA,
    tables: ['stake_txes'],
    filenames: ['euphrates_stake.csv'],
    password: env.PASSWORD_DEV,
  });

  console.log(`data fetching finished! ${rawData.length} rows fetched`);

  const data = transformCSV(rawData);

  await uploadToDune({
    data,
    apiKey: env.API_KEY,
    tableName: 'euphrates_stake',
    description: 'euphrates_stake',
  });
};

main();
