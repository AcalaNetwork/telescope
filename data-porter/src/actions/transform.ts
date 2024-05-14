import { flow } from 'lodash';
import { unparse } from 'papaparse';

import { Row } from './pull';

const pickColumns = (columns: string[]) => (csvData: any[]) => csvData.map(d =>
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

const toSimpleTimestamp = <T extends Row>(csvData: T[]) => csvData.map<T>(rowData => ({
  ...rowData,
  timestamp: formatDate(rowData.timestamp),
}));

export const transformData = flow<[Row[]], Row[], string>(
  // pickColumns(['timestamp', 'pool_id', 'amount', 'from', 'type']),
  toSimpleTimestamp,
  unparse,
);
