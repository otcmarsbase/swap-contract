// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./../interfaces/IERC20.sol";
import "./../interfaces/IUniswapV2Router02.sol";
import "./../interfaces/IUniswapV2Factory.sol";

import "./../interfaces/IMarsbaseSink.sol";
import "./../interfaces/IMarsbaseTreasury.sol";

contract EtheriumSwap is IMarsbaseSink, IMarsbaseTreasury {
    address internal constant UNISWAP_FACTORY_ADDRESS =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IUniswapV2Factory public uniswapFactory;
    IUniswapV2Router02 public uniswapRouter;
    address private owner;

    address private WETH;
    address private TOKEN_OUT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // Etherium mainnet USDT

    constructor() {
        owner = address(msg.sender);
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        uniswapFactory = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS);
        WETH = uniswapRouter.WETH();
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
            IERC20(token).approve(UNISWAP_ROUTER_ADDRESS, amount),
            "approve failed."
        );

        address pair = uniswapFactory.getPair(token, TOKEN_OUT);
        if (pair != 0x0000000000000000000000000000000000000000) {
            uniswapRouter.swapExactTokensForTokens(
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
