export const DUNE_URL = 'https://api.dune.com/api/v1/table/upload/csv';

export const DB_CONFIG_PROD = {
  host: 'evm-subql-cluster.cluster-ro-cwi35kgo8jvg.ap-southeast-1.rds.amazonaws.com',
  port: 5432,
  database: 'postgres',
  user: 'postgres_ro',
};

export const DB_CONFIG_DEV = {
  host: 'subql-evm.cluster-cspmstlhvanj.ap-southeast-1.rds.amazonaws.com',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
};
