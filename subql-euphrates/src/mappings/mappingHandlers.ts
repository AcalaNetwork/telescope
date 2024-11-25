import assert from "assert";

import {
  ClaimRewardLog,
  StakeLog, UnstakeLog,
} from "../types/abi-interfaces/Staking";
import { Claim, EuphratesTx, PoolStats } from "../types";
import { getPoolStats, shareToTokenAmount, toCoreTokenAmount } from "./utils";
import { EthereumBlock } from "@subql/types-ethereum";
import { Erc20__factory } from "../typechain";
import { Addr, Decimals } from "./consts";
import { formatUnits } from "ethers/lib/utils";

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
  const { dotAmount, dotAmountUi, jitosolAmount, jitosolAmountUi } = await toCoreTokenAmount(tokenAmount, poolId, blockNumber);

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
    jitosolAmount,
    tokenAmountUi,
    dotAmountUi,
    jitosolAmountUi,
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
  const { dotAmount, dotAmountUi, jitosolAmount, jitosolAmountUi } = await toCoreTokenAmount(tokenAmount, poolId, blockNumber);

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
    jitosolAmount,
    tokenAmountUi,
    dotAmountUi,
    jitosolAmountUi,
  });

  await tx.save();
}

export async function handleClaim(log: ClaimRewardLog): Promise<void> {
  logger.info("new claim at block " + log.blockNumber.toString());
  const { args, blockNumber, transactionHash, transactionIndex, transaction } = log;
  assert(args, "cannot find args on the logs");

  let decimals = Decimals.Jitosol;
  if (args.rewardType === Addr.Tai) {   // TAI
    decimals = Decimals.Tai;
  } else {
    const token = Erc20__factory.connect(args.rewardType, api);
    decimals = await token.decimals();
  }

  const amountUi = Number(formatUnits(args.amount.toBigInt(), decimals));

  const type = TxType.Claim;
  const tx = Claim.create({
    id: `${type}-${blockNumber}-${transactionIndex}-${log.logIndex}`,
    timestamp: new Date(Number(transaction.blockTimestamp * 1000n)),
    txHash: transactionHash,
    blockNumber,
    poolId: args.poolId.toNumber(),
    recipient: args.sender,
    amount: args.amount.toBigInt(),
    amountUi,
    rewardType: args.rewardType,
  });

  await tx.save();
}

const EUPHRATES_POOLS = [0, 1, 2, 3, 4, 5, 6, 7];
export async function getEuphratesStatsFromBlock(block: EthereumBlock): Promise<void> {
  const poolStats = await Promise.all(EUPHRATES_POOLS.map(poolId => getPoolStats(poolId, block.number)));
  logger.info("new euphrates stats at block " + block.number.toString());

  const statEntities = poolStats.map(stat => PoolStats.create({
      id: `${block.number}-${stat.poolId}`,
      timestamp: new Date(Number(block.timestamp * 1000n)),
      ...stat,
    })
  );

  store.bulkCreate('PoolStats', statEntities);
}
