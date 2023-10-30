import axios from 'axios';
import fs from 'fs/promises';

import { readCSV } from '../utils';

const DUNE_URL = 'https://api.dune.com/api/v1/table/upload/csv';

interface UploadParamsBase {
  tableName: string,
  filename: string,
  apiKey: string,
}

interface UploadParamsDune extends UploadParamsBase {
  description: string,
}

export const uploadToDune = async ({
  filename,
  apiKey,
  tableName,
  description,
}: UploadParamsDune) => {
  console.log(`uploading data to dune table ${tableName} ...`);
  const data = await fs.readFile(filename, 'utf-8');

  const headers = {
    'X-Dune-Api-Key': apiKey,
  };

  const payload = {
    table_name: tableName,
    description: description,
    is_private: false,
    data,
  };

  const res = await axios.post(DUNE_URL, payload, { headers });

  if (res.status !== 200 || res.data.success !== true) {
    throw new Error(`upload data to Dune failed: ${JSON.stringify(res)}`);
  }

  console.log('upload finished!');

  return res.data;
};
