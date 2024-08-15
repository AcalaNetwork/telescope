import assert from "assert";

import {
  StakeLog, UnstakeLog,
} from "../types/abi-interfaces/Staking";
import { EuphratesTx, PoolStats } from "../types";
import { getPoolStats, shareToTokenAmount, tokenAmountToDotAmount } from "./utils";
import { EthereumBlock } from "@subql/types-ethereum";

enum TxType {
  Claim = 'claim',
  Stake = 'stake',
  Unstake = 'unstake',
}

export async function handleStake(log: StakeLog): Promise<void> {
  logger.info("new staking at block " + log.blockNumber.toString());
  const { args, blockNumber, transactionHash, transactionIndex, transaction } = log;
  assert(args, "cannot find args on the logs");

  const recipient = args.sender;
  const poolId = args.poolId.toNumber();
  const shareAmount = args.amount.toBigInt();
  const { tokenAmount, tokenAmountUi } = await shareToTokenAmount(shareAmount, poolId);
  const { dotAmount, dotAmountUi } = await tokenAmountToDotAmount(tokenAmount, poolId);

  const type = TxType.Stake;
  const tx = EuphratesTx.create({
    id: `${type}-${blockNumber}-${transactionIndex}`,
    txHash: transactionHash,
    timestamp: new Date(Number(transaction.blockTimestamp * 1000n) ),
    type,
    blockNumber,
    recipient,
    poolId,
    shareAmount,
    tokenAmount,
    dotAmount,
    tokenAmountUi,
    dotAmountUi,
  });

  await tx.save();
}

export async function handleUnstake(log: UnstakeLog): Promise<void> {
  logger.info("new unstaking at block " + log.blockNumber.toString());
  const { args, blockNumber, transactionHash, transactionIndex, transaction } = log;
  assert(args, "cannot find args on the logs");

  const recipient = args.sender;
  const poolId = args.poolId.toNumber();
  const shareAmount = args.amount.toBigInt();
  const { tokenAmount, tokenAmountUi } = await shareToTokenAmount(shareAmount, poolId);
  const { dotAmount, dotAmountUi } = await tokenAmountToDotAmount(tokenAmount, poolId);

  const type = TxType.Unstake;
  const tx = EuphratesTx.create({
    id: `${type}-${blockNumber}-${transactionIndex}`,
    txHash: transactionHash,
    timestamp: new Date(Number(transaction.blockTimestamp * 1000n) ),
    type,
    blockNumber,
    recipient,
    poolId,
    shareAmount,
    tokenAmount,
    dotAmount,
    tokenAmountUi,
    dotAmountUi,
  });

  await tx.save();
}

const EUPHRATES_POOLS = [0, 1, 2, 3, 4, 5, 6];
export async function getEuphratesStatsFromBlock(block: EthereumBlock): Promise<void> {
  const poolStats = await Promise.all(EUPHRATES_POOLS.map(getPoolStats));
  logger.info("new euphrates stats at block " + block.number.toString());
  logger.info(JSON.stringify(poolStats, (_key, value) =>
    typeof value === 'bigint' ? value.toString() : value
  ));

  await Promise.all(poolStats.map(async stat => {
    const pool = PoolStats.create({
      id: `${block.number}-${stat.poolId}`,
      timestamp: new Date(Number(block.timestamp * 1000n)),
      ...stat,
    });

    await pool.save();
  }));
}
