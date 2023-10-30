import axios from 'axios';

const DUNE_URL = 'https://api.dune.com/api/v1/table/upload/csv';

interface UploadParams {
  data: string,
  description: string,
  tableName: string,
  apiKey: string,
}

export const uploadToDune = async ({
  data,
  apiKey,
  tableName,
  description,
}: UploadParams) => {
  console.log(`uploading data to dune table ${tableName} ...`);

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
