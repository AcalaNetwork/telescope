
import { formatUnits } from "ethers/lib/utils";

import { Euphrates__factory, Homa__factory, Wtdot__factory } from "../typechain";

const HOMA_ADDR = '0x0000000000000000000000000000000000000805';
const EUPHRATES_ADDR = '0x7Fe92EC600F15cD25253b421bc151c51b0276b7D';
const WTDOT_ADDR = '0xe1bD4306A178f86a9214c39ABCD53D021bEDb0f9';

export const ldotToDotAmount = async (amount: bigint): Promise<bigint> => {
  const homa = Homa__factory.connect(HOMA_ADDR, api);

  const exchangeRate = await homa.getExchangeRate();
  return amount * exchangeRate.toBigInt() / BigInt(1e18);
}

export const wtdotToDotAmount = async (amount: bigint): Promise<bigint> => {
  const wtdot = Wtdot__factory.connect(WTDOT_ADDR, api);

  const withdrawRate = await wtdot.withdrawRate();  
  const tdotAmount = amount * withdrawRate.toBigInt() / BigInt(1e18);

  return tdotAmount;    // TREAT 1 tdot = 1 dot
}

const LCDOT_CONVERT_BLOCK = 4736804;
export const tokenAmountToDotAmount = async (
  tokenAmount: bigint,
  poolId: number,
  blockNumber: number,
) => {
  let dotAmount = 0n;
  if ([0, 2, 5].includes(poolId)) {
    dotAmount = poolId === 0 && blockNumber < LCDOT_CONVERT_BLOCK
      ? tokenAmount   // before lcdot was converted, token is still lcdot
      : await ldotToDotAmount(tokenAmount);
  } else if ([1, 3].includes(poolId)) {
    dotAmount = poolId === 1 && blockNumber < LCDOT_CONVERT_BLOCK
      ? tokenAmount   // before lcdot was converted, token is still lcdot
      : await wtdotToDotAmount(tokenAmount);
  } else if ([4].includes(poolId)) {
    dotAmount = tokenAmount;
  }

  const dotAmountUi = Number(formatUnits(dotAmount, 10));
  return { dotAmount, dotAmountUi };
};

const getShareTokenDecimals = (poolId: number) => (
  poolId <= 5
    ? 10  // ldot, dot or wtdot
    : 9   // jitosol
)

export const shareToTokenAmount = async (
  shareAmount: bigint,
  poolId: number,
) => {
  const euphrates = Euphrates__factory.connect(EUPHRATES_ADDR, api);

  let eachangeRate = poolId <= 5
    ? (await euphrates.convertInfos(poolId)).convertedExchangeRate.toBigInt()
    : BigInt(1e18);     // 1:1, no conversion

  if (eachangeRate === 0n) {    // before lcdot was converted
    eachangeRate = BigInt(1e18);
  }

  const tokenAmount = shareAmount * eachangeRate / BigInt(1e18);
  const tokenAmountUi = Number(formatUnits(tokenAmount, getShareTokenDecimals(poolId)));

  return { tokenAmount, tokenAmountUi };
};

export const getPoolStats = async (
  poolId: number,
  blockNumber: number,
) => {
  const euphrates = Euphrates__factory.connect(EUPHRATES_ADDR, api);

  const totalShares = await euphrates.totalShares(poolId);
  const { tokenAmount, tokenAmountUi } = await shareToTokenAmount(totalShares.toBigInt(), poolId);
  const { dotAmount, dotAmountUi } = await tokenAmountToDotAmount(tokenAmount, poolId, blockNumber);

  return {
    poolId,
    tokenAmount,
    dotAmount,
    tokenAmountUi,
    dotAmountUi,
  };
}
