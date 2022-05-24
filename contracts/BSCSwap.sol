// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./../interfaces/IERC20.sol";
import "./../interfaces/IUniswapV2Router02.sol";
import "./../interfaces/IUniswapV2Factory.sol";

import "./../interfaces/IMarsbaseSink.sol";
import "./../interfaces/IMarsbaseTreasury.sol";

contract BCSSwap is IMarsbaseSink, IMarsbaseTreasury {
    address internal constant PANCAKE_FACTORY_ADDRESS =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address internal constant PANCAKE_ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    IUniswapV2Factory public pancakeFactory;
    IUniswapV2Router02 public pancakeRouter;
    address private owner;

    address private WETH;
    address private TOKEN_OUT = 0x55d398326f99059fF775485246999027B3197955; // BSC mainnet USDT

    constructor() {
        owner = address(msg.sender);
        pancakeRouter = IUniswapV2Router02(PANCAKE_ROUTER_ADDRESS);
        pancakeFactory = IUniswapV2Factory(PANCAKE_FACTORY_ADDRESS);
        WETH = pancakeRouter.WETH();
    }

    function takeAndSwap(
        address from,
        address token,
        uint256 amount,
        address receiver
    ) external override {
        require(
            IERC20(token).transferFrom(from, address(this), amount),
            "transferFrom failded."
        );

        require(
            IERC20(token).approve(PANCAKE_ROUTER_ADDRESS, amount),
            "approve failed."
        );

        address pair = pancakeFactory.getPair(token, TOKEN_OUT);
        if (pair != 0x0000000000000000000000000000000000000000) {
            pancakeRouter.swapExactTokensForTokens(
                amount,
                0,
                getPath(token),
                receiver,
                block.timestamp
            );
        }
    }

    function withdraw(
        address receiver,
        uint256 amount,
        uint64 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        // TODO:
    }

    function setTokenOut(address tokenOut) external {
        require(owner == msg.sender, "Rejected!");
        TOKEN_OUT = tokenOut;
    }

    function getTokenOut() external view returns (address tokenOut) {
        return TOKEN_OUT;
    }

    function getPath(address tokenFrom)
        private
        view
        returns (address[] memory)
    {
        address[] memory path;
        if (tokenFrom == WETH || TOKEN_OUT == WETH) {
            path = new address[](2);
            path[0] = tokenFrom;
            path[1] = TOKEN_OUT;
        } else {
            path = new address[](3);
            path[0] = tokenFrom;
            path[1] = WETH;
            path[2] = TOKEN_OUT;
        }

        return path;
    }
}
