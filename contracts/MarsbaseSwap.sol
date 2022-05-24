// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./../interfaces/IERC20.sol";
import "./../interfaces/IUniswapV2Router02.sol";
import "./../interfaces/IUniswapV2Factory.sol";

import "./../interfaces/IMarsbaseSink.sol";
import "./../interfaces/IMarsbaseTreasury.sol";

contract MarsbaseSwap is IMarsbaseSink, IMarsbaseTreasury {
    address internal FACTORY_ADDRESS;
    address internal ROUTER_ADDRESS;

    IUniswapV2Factory public factory;
    IUniswapV2Router02 public router;
    address private owner;

    address private WETH;
    address private TOKEN_OUT; // Etherium mainnet USDT

    constructor(
        address routerAddress,
        address factoryAddress,
        address tokenOut
    ) {
        owner = address(msg.sender);

        ROUTER_ADDRESS = routerAddress;
        FACTORY_ADDRESS = factoryAddress;

        router = IUniswapV2Router02(routerAddress);
        factory = IUniswapV2Factory(factoryAddress);
        TOKEN_OUT = tokenOut;
        WETH = router.WETH();
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
            IERC20(token).approve(ROUTER_ADDRESS, amount),
            "approve failed."
        );

        address pair = factory.getPair(token, TOKEN_OUT);
        if (pair != 0x0000000000000000000000000000000000000000) {
            router.swapExactTokensForTokens(
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
