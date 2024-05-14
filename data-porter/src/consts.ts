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

export const DB_CONFIG_STAGING = {
  host: '',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
};

export const DB_CONFIG_LOCAL = {
  host: '0.0.0.0',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
};

export enum DbType {
  PROD = 'prod',
  STAGING = 'staging',
  DEV = 'dev',
  LOCAL = 'local',
}

export const getDbConfig = (dbType: DbType) => {
  switch (dbType) {
    case DbType.PROD:
      return DB_CONFIG_PROD;
    case DbType.DEV:
      return DB_CONFIG_DEV;
    case DbType.STAGING:
      return DB_CONFIG_STAGING;
    case DbType.LOCAL:
      return DB_CONFIG_LOCAL;

    default:
      throw new Error(`<getDbConfig> invalid db type: ${dbType}`);
  }
};
