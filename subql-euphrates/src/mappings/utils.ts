
import { formatUnits } from "ethers/lib/utils";

import { Euphrates__factory, Homa__factory, Wtdot__factory, Dex__factory, Erc20__factory } from "../typechain";
import { Addr, Decimals } from "./consts";

export const ldotToDotAmount = async (amount: bigint): Promise<bigint> => {
  const homa = Homa__factory.connect(Addr.Homa, api);

  const exchangeRate = await homa.getExchangeRate();
  return amount * exchangeRate.toBigInt() / BigInt(1e18);
}

export const wtdotToDotAmount = async (amount: bigint): Promise<bigint> => {
  const wtdot = Wtdot__factory.connect(Addr.Wtdot, api);

  const withdrawRate = await wtdot.withdrawRate();
  const tdotAmount = amount * withdrawRate.toBigInt() / BigInt(1e18);

  return tdotAmount;    // TREAT 1 tdot = 1 dot
}

// only pool 7 now
export const parseLpTokenAmount = async (lpAmount: bigint) => {

  try {
    const dex = Dex__factory.connect(Addr.Dex, api);
    const lp = Erc20__factory.connect(Addr.JitosolLdotLp, api);

    const lpTotalSupply = (await lp.totalSupply()).toBigInt();
    const [jitosolLiq, ldotLiq] = (await dex.getLiquidityPool(Addr.Jitosol, Addr.Ldot)).map(x => x.toBigInt());

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

  const dotAmountUi = Number(formatUnits(dotAmount, Decimals.DotFamily));
  const jitosolAmountUi = Number(formatUnits(jitosolAmount, Decimals.Jitosol));

  return {
    dotAmount,
    dotAmountUi,
    jitosolAmount,
    jitosolAmountUi,
  };
};

const getShareTokenDecimals = (poolId: number) => (
  poolId === 6
    ? Decimals.Jitosol
    : Decimals.DotFamily
)

export const shareToTokenAmount = async (
  shareAmount: bigint,
  poolId: number,
) => {
  const euphrates = Euphrates__factory.connect(Addr.Euphrates, api);

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
  const euphrates = Euphrates__factory.connect(Addr.Euphrates, api);

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
