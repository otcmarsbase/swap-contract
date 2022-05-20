// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IMarsbaseSink {
    function takeAndSwap(
        address from,
        address token,
        uint256 amount
    ) external;
}

interface IMarsbaseTreasury {
    function withdraw(
        address receiver,
        uint256 amount,
        uint64 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

contract EtheriumSwap is IMarsbaseSink, IMarsbaseTreasury {
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IUniswapV2Router02 public uniswapRouter;
    address private owner;

    address private WETH;
    address private TOKEN_OUT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // Etherium mainnet USDT

    constructor() {
        owner = address(msg.sender);
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        WETH = uniswapRouter.WETH();
    }

    function takeAndSwap(
        address from,
        address token,
        uint256 amount
    ) external override {
        require(
            IERC20(token).transferFrom(from, address(this), amount),
            "transferFrom failded."
        );

        require(
            IERC20(token).approve(UNISWAP_ROUTER_ADDRESS, amount),
            "approve failed."
        );

        uniswapRouter.swapExactTokensForTokens(
            amount,
            0,
            getPath(token),
            address(this),
            block.timestamp
        );
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
