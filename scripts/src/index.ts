import { cleanEnv, str } from 'envalid';
import dotenv from 'dotenv';

import { DB_CONFIG_DEV, DB_CONFIG_PROD } from './consts';
import {
  pullDataFromDb,
  transformCSV,
  uploadToDune,
} from './actions';

dotenv.config();

const env = cleanEnv(process.env, {
  PASSWORD_PROD: str(),
  PASSWORD_DEV: str(),
  API_KEY: str(),
});

const main = async () => {
  // const logFile = './acala_logs.csv';
  // const receiptFile = './acala_receipts.csv';
  // const euphratesFile = './euphrates_stake.csv';

  // const [logFile, receiptFile] = await pullDataFromDb({
  //   ...DB_CONFIG_PROD,
  //   schema: 'evm-acala-2',
  //   tables: ['logs', 'transaction_receipts'],
  //   filenames: ['acala_logs.csv', 'acala_receipts.csv'],
  //   password: env.PASSWORD_PROD,
  // });

  const [euphratesFile] = await pullDataFromDb({
    ...DB_CONFIG_DEV,
    schema: 'euphrates-2',
    tables: ['stake_txes'],
    filenames: ['euphrates_stake.csv'],
    password: env.PASSWORD_DEV,
  });

  await Promise.all([
    // transformCSV(logFile),
    // transformCSV(receiptFile),
    transformCSV(euphratesFile),
  ]);

  await uploadToDune({
    filename: euphratesFile,
    apiKey: env.API_KEY,
    tableName: 'euphrates_stake',
    description: 'euphrates_stake',
  });
};

main();
