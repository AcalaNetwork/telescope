import {
  StakeLog, UnstakeLog,
} from "../types/abi-interfaces/Staking";
import { StakeTx } from "../types";
import assert from "assert";

export async function handleStake(log: StakeLog): Promise<void> {
  logger.info("new staking at block " + log.blockNumber.toString());

  assert(log.args, "Require args on the logs");

  const tx = StakeTx.create({
    type: 1,  // stake
    id: log.transactionHash,
    txHash: log.transactionHash,
    from: log.transaction.from,
    blockNumber: log.blockNumber,
    timestamp: new Date(Number(log.transaction.blockTimestamp * 1000n) ),
    poolId: log.args.poolId.toNumber(),
    amount: log.args.amount.toBigInt(),
  });

  await tx.save();
}

export async function handleUnstake(log: UnstakeLog): Promise<void> {
  logger.info("new unstaking at block " + log.blockNumber.toString());

  assert(log.args, "Require args on the logs");

  const tx = StakeTx.create({
    type: 0,  // unstake
    id: log.transactionHash,
    txHash: log.transactionHash,
    from: log.transaction.from,
    blockNumber: log.blockNumber,
    timestamp: new Date(Number(log.transaction.blockTimestamp * 1000n) ),
    poolId: log.args.poolId.toNumber(),
    amount: log.args.amount.toBigInt(),
  });

  await tx.save();
}
