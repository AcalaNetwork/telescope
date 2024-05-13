import { SubstrateBlock } from "@subql/types";
import { formatUnits } from "@ethersproject/units";

import { HomaState } from "../types";

const LDOT_DECIMALS = 10;
const BLOCKS_IN_AN_HOUR = 60 * 60 / 12;
const BLOCKS_IN_A_DAY = BLOCKS_IN_AN_HOUR * 24;
const BLOCKS_IN_A_MONTH = BLOCKS_IN_A_DAY * 30;
const DEFAULT_APY = 0.145;

export async function handleBlock(block: SubstrateBlock): Promise<void> {
  const liquidToken = api.consts.homa.liquidCurrencyId;
  const [rawBonded, rawTotalVoidLiquid, rawToBondPool, rawLiquidIssuance] = await Promise.all([
    api.query.homa.totalStakingBonded(),
    api.query.homa.totalVoidLiquid(),
    api.query.homa.toBondPool(),
    api.query.tokens.totalIssuance(liquidToken),
  ]);

  const bonded = rawBonded.toBigInt();
  const toBondPool = rawToBondPool.toBigInt();
  const liquidIssuance = rawLiquidIssuance.toBigInt();
  const totalVoidLiquid = rawTotalVoidLiquid.toBigInt();

  const totalBonded = toBondPool + bonded;
  const exchangeRate = totalBonded * BigInt(10 ** LDOT_DECIMALS) / (liquidIssuance + totalVoidLiquid);

  const { hash, number } = block.block.header;
  const blockHash = hash.toString();
  const blockNumber = number.toNumber();
  const id = `homa-${blockNumber}`;
  const timestamp = block.timestamp;

  const blockNumberMonthAgo = blockNumber - BLOCKS_IN_A_MONTH;
  const homaStateMonthAgo = await HomaState.get(`homa-${blockNumberMonthAgo}`);

  let apy = DEFAULT_APY;
  if (homaStateMonthAgo) {
    const r0 = Number(formatUnits(homaStateMonthAgo.exchangeRate, LDOT_DECIMALS));
    const r1 = Number(formatUnits(exchangeRate, LDOT_DECIMALS));
    const rateDiffMonth = r1 / r0;
    apy = Number((rateDiffMonth ** (365 / 30) - 1).toFixed(8));
  }

  const homaState = new HomaState(
    id,
    toBondPool,
    bonded,
    totalBonded,
    liquidIssuance,
    totalVoidLiquid,
    exchangeRate,
    apy,
    timestamp,
    blockNumber,
    blockHash,
  );

  await homaState.save(); 
}
