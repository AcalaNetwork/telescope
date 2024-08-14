import assert from "assert";

import {
  StakeLog, UnstakeLog,
} from "../types/abi-interfaces/Staking";
import { EuphratesTx } from "../types";
import { shareToTokenAmount, tokenAmountToDotAmount } from "./utils";

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
  const tokenAmount = await shareToTokenAmount(shareAmount, poolId);
  const dotAmount = await tokenAmountToDotAmount(tokenAmount, poolId);

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
  const tokenAmount = await shareToTokenAmount(shareAmount, poolId);
  const dotAmount = await tokenAmountToDotAmount(tokenAmount, poolId);

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
  });

  await tx.save();
}
