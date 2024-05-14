import assert from "assert";

import {
  StakeLog, UnstakeLog,
} from "../types/abi-interfaces/Staking";
import { StakeTx } from "../types";
import { Homa__factory } from "../typechain";

const HOMA_ADDR = '0x0000000000000000000000000000000000000805';
const homa = Homa__factory.connect(HOMA_ADDR, api);

export const ldotToDotAmount = async (amount: bigint): Promise<bigint> => {
  const exchangeRate = await homa.getExchangeRate();
  return amount * exchangeRate.toBigInt() / BigInt(1e18);
}

export async function handleStake(log: StakeLog): Promise<void> {
  logger.info("new staking at block " + log.blockNumber.toString());
  assert(log.args, "Require args on the logs");

  const poolId = log.args.poolId.toNumber();
  let amount = log.args.amount.toBigInt();
  const originalAmount = amount;

  if (poolId === 5) {   // amount is in LDOT
    amount = await ldotToDotAmount(amount)
  }

  const tx = StakeTx.create({
    type: 1,  // stake
    id: log.transactionHash,
    txHash: log.transactionHash,
    from: log.transaction.from,
    blockNumber: log.blockNumber,
    timestamp: new Date(Number(log.transaction.blockTimestamp * 1000n) ),
    poolId,
    amount,
    originalAmount,
  });

  await tx.save();
}

export async function handleUnstake(log: UnstakeLog): Promise<void> {
  logger.info("new unstaking at block " + log.blockNumber.toString());
  assert(log.args, "Require args on the logs");

  const poolId = log.args.poolId.toNumber();
  let amount = log.args.amount.toBigInt();
  const originalAmount = amount;

  if (poolId === 5) {   // rawAmount is in LDOT
    amount = await ldotToDotAmount(amount)
  }

  const tx = StakeTx.create({
    type: 0,  // unstake
    id: log.transactionHash,
    txHash: log.transactionHash,
    from: log.transaction.from,
    blockNumber: log.blockNumber,
    timestamp: new Date(Number(log.transaction.blockTimestamp * 1000n) ),
    poolId,
    amount,
    originalAmount,
  });

  await tx.save();
}
