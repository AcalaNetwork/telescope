import { subqlTest } from "@subql/testing";
import { EuphratesTx, PoolStats } from "../types";

subqlTest(
  "getEuphratesStatsFromBlock", // test name
  7386705, // block height to process
  // 7986705, // block height to process
  // 7394050, // block height to process
  [], // dependent entities
  [], // expected entities
  "getEuphratesStatsFromBlock", //handler name
);