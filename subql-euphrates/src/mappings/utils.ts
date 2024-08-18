
import { formatUnits } from "ethers/lib/utils";
import { Dex__factory, Erc20__factory, Euphrates__factory, Homa__factory, Wtdot__factory } from "../typechain";

const DEX_ADDR = '0x0000000000000000000000000000000000000803';
const HOMA_ADDR = '0x0000000000000000000000000000000000000805';
const DOT_ADDR = '0x0000000000000000000100000000000000000002';
const LDOT_ADDR = '0x0000000000000000000100000000000000000003';
const TDOT_ADDR = '0x0000000000000000000300000000000000000000';
const EUPHRATES_ADDR = '0x7Fe92EC600F15cD25253b421bc151c51b0276b7D';
const WTDOT_ADDR = '0xe1bD4306A178f86a9214c39ABCD53D021bEDb0f9';

export const ldotToDotAmount = async (amount: bigint): Promise<bigint> => {
  const homa = Homa__factory.connect(HOMA_ADDR, api);

  const exchangeRate = await homa.getExchangeRate();
  return amount * exchangeRate.toBigInt() / BigInt(1e18);
}

export const wtdotToDotAmount = async (amount: bigint): Promise<bigint> => {
  return amount;    // TODO: more accurate calculation

  // const wtdot = Wtdot__factory.connect(WTDOT_ADDR, api);
  // const dex = Dex__factory.connect(DEX_ADDR, api);
  // const tdot = Erc20__factory.connect(TDOT_ADDR, api);

  // const [
  //   withdrawRate,
  //   [dotLiquidity],
  //   tdotTotalSupply
  // ] = await Promise.all([
  //   wtdot.withdrawRate(),
  //   dex.getLiquidityPool(DOT_ADDR, LDOT_ADDR),
  //   tdot.totalSupply(),
  // ]);
  
  // const tdotAmount = amount * withdrawRate.toBigInt() / BigInt(1e18);
  // const dotAmount = tdotAmount * dotLiquidity.toBigInt() / tdotTotalSupply.toBigInt();
  // return dotAmount * 2n;    // another half is ldot
}

export const tokenAmountToDotAmount = async (
  tokenAmount: bigint,
  poolId: number,
) => {
  let dotAmount = 0n;
  if ([0, 2, 5].includes(poolId)) {
    dotAmount = await ldotToDotAmount(tokenAmount);
  } else if ([1, 3].includes(poolId)) {
    dotAmount = await wtdotToDotAmount(tokenAmount);
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

export const getPoolStats = async (poolId: number) => {
  const euphrates = Euphrates__factory.connect(EUPHRATES_ADDR, api);

  const totalShares = await euphrates.totalShares(poolId);
  const { tokenAmount, tokenAmountUi } = await shareToTokenAmount(totalShares.toBigInt(), poolId);
  const { dotAmount, dotAmountUi } = await tokenAmountToDotAmount(tokenAmount, poolId);

  return {
    poolId,
    tokenAmount,
    dotAmount,
    tokenAmountUi,
    dotAmountUi,
  };
}
