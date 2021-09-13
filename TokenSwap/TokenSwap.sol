// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract TokenSwap {
    ISwapRouter public immutable swapRouter;
    IQuoter public immutable quoter;

    address public constant oWBTC = 0x379c28627e0D2b219E69511Fd4CB6cFa5Db6D3f1;
    address public constant oWETH = 0x4DB30144d2037E483C442f8FA470Af00E08A6654;

    uint24 public constant poolFee = 500;

    constructor(ISwapRouter _swapRouter, IQuoter _quoter) {
        swapRouter = _swapRouter;
        quoter = _quoter;
    }
    
    function getBTCBalance() public view returns (uint256) {
        return IERC20(oWBTC).balanceOf(address(this));
    }
    
    function getETHBalance() public view returns (uint256) {
        return IERC20(oWETH).balanceOf(address(this));
    }

    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        IERC20(oWBTC).approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: oWBTC,
                tokenOut: oWETH,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }
    
    function getQuoteExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        return quoter.quoteExactInputSingle(oWBTC, oWETH, poolFee, amountIn, 0);
    }
}
