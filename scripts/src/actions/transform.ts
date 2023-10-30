import { readCSV, writeCSV } from '../utils';

// truncate *last* x percent of data
const _truncate = async (csvData: any[], percent: number) => {
  if (percent <= 0 || percent > 100) {
    throw new Error('invalid truncate percent');
  }

  const rowCount = csvData.length;
  const rowsToExtract = Math.ceil(rowCount * (percent / 100));
  return csvData.slice(-rowsToExtract);
};

const pickColumns = (csvData: any[], columns: string[]) => csvData.map(d => 
  columns.reduce((acc, col) => ({ ...acc, [col]: d[col] }), {}),
);

// this shape is compatible with dune
// TODO: there should be a lib that does this?
const formatDate = (input: string): string => {
  const date = new Date(input);

  const YYYY = date.getFullYear();
  const MM = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-based, so we add 1
  const DD = String(date.getDate()).padStart(2, '0');
  const HH = String(date.getHours()).padStart(2, '0');
  const mm = String(date.getMinutes()).padStart(2, '0');
  const ss = String(date.getSeconds()).padStart(2, '0');

  return `${YYYY}-${MM}-${DD} ${HH}:${mm}:${ss}`;
};

const toSimpleTimestamp = (csvData: any[]) => csvData.map(rowData => ({
  ...rowData,
  timestamp: formatDate(rowData.timestamp),
}));

export async function transformCSV(filename: string): Promise<void> {
  console.log(`transforming ${filename} ...`);
  const rawData = await readCSV(filename);
  const data = toSimpleTimestamp(pickColumns(rawData, ['timestamp', 'pool_id', 'amount', 'from', 'type']));

  await writeCSV(filename, data);
  console.log('transformation finished!');
}
