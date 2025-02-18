import {
  EthereumProject,
  EthereumDatasourceKind,
  EthereumHandlerKind,
} from "@subql/types-ethereum";

// Can expand the Datasource processor types via the generic param
const project: EthereumProject = {
  specVersion: "1.0.0",
  version: "1.0.0",
  name: "euphrates stats",
  description:
    "",
  runner: {
    node: {
      name: "@subql/node-ethereum",
      version: ">=3.0.0",
    },
    query: {
      name: "@subql/query",
      version: "*",
    },
  },
  schema: {
    file: "./schema.graphql",
  },
  network: {
    /**
     * chainId is the EVM Chain ID, for Ethereum this is 1
     * https://chainlist.org/chain/1
     */
    chainId: "787",
    /**
     * This endpoint must be a public non-pruned archive node
     * Public nodes may be rate limited, which can affect indexing speed
     * When developing your project we suggest getting a private API key
     * You can get them from OnFinality for free https://app.onfinality.io
     * https://documentation.onfinality.io/support/the-enhanced-api-service
     */
    endpoint: [ "https://eth-rpc-acala.aca-api.network" ],
    // dictionary: "https://gx.api.subquery.network/sq/subquery/eth-dictionary",
  },
  dataSources: [
    {
      kind: EthereumDatasourceKind.Runtime,
      startBlock: 4538000,
      options: {
        // Must be a key of assets
        abi: "staking",
        address: "0x7Fe92EC600F15cD25253b421bc151c51b0276b7D",
      },
      assets: new Map([["staking", { file: "./abis/Staking.json" }]]),
      mapping: {
        file: "./dist/index.js",
        handlers: [
          {
            kind: EthereumHandlerKind.Event,
            handler: "handleStake",
            filter: {
              topics: ["Stake(address,uint256,uint256)"],
            },
          },
          {
            kind: EthereumHandlerKind.Event,
            handler: "handleUnstake",
            filter: {
              topics: ["Unstake(address,uint256,uint256)"],
            },
          },
          {
            kind: EthereumHandlerKind.Event,
            handler: "handleClaim",
            filter: {
              topics: ["ClaimReward(address,uint256,address,uint256)"],
            },
          },
          {
            kind: EthereumHandlerKind.Block,
            handler: "getEuphratesStatsFromBlock",
            filter: {
              modulo: 8 * 60 * 60 / 12,   // every 8 hours
            },
          },
        ],
      },
    },
  ],
  repository: "https://github.com/subquery/ethereum-subql-starter",
};

// Must set default to the project instance
export default project;
