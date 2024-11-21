
import { formatUnits } from "ethers/lib/utils";

import { Euphrates__factory, Homa__factory, Wtdot__factory, Dex__factory, Erc20__factory } from "../typechain";

const HOMA_ADDR = '0x0000000000000000000000000000000000000805';
const DEX_ADDR = '0x0000000000000000000000000000000000000803';

const EUPHRATES_ADDR = '0x7Fe92EC600F15cD25253b421bc151c51b0276b7D';
const WTDOT_ADDR = '0xe1bD4306A178f86a9214c39ABCD53D021bEDb0f9';
const JITOSOL_ADDR = '0xA7fB00459F5896C3bD4df97870b44e868Ae663D7';
const LDOT_ADDR = '0x0000000000000000000100000000000000000003';
const JITOSOL_LDOT_LP_ADDR = '0x00000000000000000002000000000301A7fB0045';

const JITOSOL_DECIMALS = 9;
const OTHERS_DECIMALS = 10;

// const JITOSOL_LDOT_LP_DEPLOY_BLOCK = 7303940;

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

// only pool 7 now
export const parseLpTokenAmount = async (lpAmount: bigint) => {

  try {
    const dex = Dex__factory.connect(DEX_ADDR, api);
    const lp = Erc20__factory.connect(JITOSOL_LDOT_LP_ADDR, api);

    const lpTotalSupply = (await lp.totalSupply()).toBigInt();
    const [jitosolLiq, ldotLiq] = (await dex.getLiquidityPool(JITOSOL_ADDR, LDOT_ADDR)).map(x => x.toBigInt());

    const jitosolAmount = lpAmount * jitosolLiq / lpTotalSupply;
    const ldotAmount = lpAmount * ldotLiq / lpTotalSupply;

    return { jitosolAmount, ldotAmount };
  } catch {
    // before lp was deployed
    return { jitosolAmount: 0n, ldotAmount: 0n };
  }
}

const LCDOT_CONVERT_BLOCK = 4736804;
export const toCoreTokenAmount = async (
  tokenAmount: bigint,
  poolId: number,
  blockNumber: number,
) => {
  let dotAmount = 0n;
  let jitosolAmount = 0n;
  if ([0, 2, 5].includes(poolId)) {
    dotAmount = poolId === 0 && blockNumber < LCDOT_CONVERT_BLOCK
      ? tokenAmount   // before lcdot was converted, token is still lcdot
      : await ldotToDotAmount(tokenAmount);
  } else if ([1, 3].includes(poolId)) {
    dotAmount = poolId === 1 && blockNumber < LCDOT_CONVERT_BLOCK
      ? tokenAmount   // before lcdot was converted, token is still lcdot
      : await wtdotToDotAmount(tokenAmount);
  } else if (poolId === 4) {
    dotAmount = tokenAmount;
  } else if (poolId === 6) {
    jitosolAmount = tokenAmount;
  } else if (poolId === 7) {
    const lpInfo = await parseLpTokenAmount(tokenAmount);
    dotAmount = await ldotToDotAmount(lpInfo.ldotAmount);
    jitosolAmount = lpInfo.jitosolAmount;
  }

  const dotAmountUi = Number(formatUnits(dotAmount, OTHERS_DECIMALS));
  const jitosolAmountUi = Number(formatUnits(jitosolAmount, JITOSOL_DECIMALS));

  return {
    dotAmount,
    dotAmountUi,
    jitosolAmount,
    jitosolAmountUi,
  };
};

const getShareTokenDecimals = (poolId: number) => (
  poolId === 6
    ? JITOSOL_DECIMALS
    : OTHERS_DECIMALS
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
  const { dotAmount, dotAmountUi, jitosolAmount, jitosolAmountUi } = await toCoreTokenAmount(tokenAmount, poolId, blockNumber);

  return {
    poolId,
    tokenAmount,
    dotAmount,
    tokenAmountUi,
    dotAmountUi,
    jitosolAmount,
    jitosolAmountUi,
  };
}
