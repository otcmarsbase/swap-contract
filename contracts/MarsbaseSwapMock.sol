// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

interface IMarsbaseSink {
    function liquidateToken(
        address from,
        address token,
        uint256 amount,
        address receiver
    ) external;
}

interface IMarsbaseTreasury {
	
	struct Coupon {
		address receiver;
		uint256 amount;
		uint256 nonce;
		uint256 chainId;
		address contractAddress;
	}
	struct CouponSig {
		uint8 v;
		bytes32 r;
		bytes32 s;
	}

	function withdraw(Coupon calldata coupon, CouponSig calldata sig) external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract MarsbaseSwapMock is IMarsbaseSink, IMarsbaseTreasury {
    address internal FACTORY_ADDRESS;
    address internal ROUTER_ADDRESS;

    IUniswapV2Factory public factory;
    IUniswapV2Router02 public router;
    address private owner;

    address private WETH;
    address private TOKEN_OUT; // Etherium mainnet USDT

    event liquidateTokenEvent(address from, address token, uint256 amount, address receiver);

    constructor(
        address routerAddress,
        address factoryAddress,
        address tokenOut
    ) {
        owner = address(msg.sender);

        // ROUTER_ADDRESS = routerAddress;
        // FACTORY_ADDRESS = factoryAddress;

        // router = IUniswapV2Router02(routerAddress);
        // factory = IUniswapV2Factory(factoryAddress);
        // TOKEN_OUT = tokenOut;
        // WETH = router.WETH();
    }

    function liquidateToken(
        address from,
        address token,
        uint256 amount,
        address receiver
    ) external override {

        emit liquidateTokenEvent(from, token, amount, receiver);
        // require(
        //     IERC20(token).transferFrom(from, address(this), amount),
        //     "transferFrom failded."
        // );

        // require(
        //     IERC20(token).approve(ROUTER_ADDRESS, amount),
        //     "approve failed."
        // );

        // address pair = factory.getPair(token, TOKEN_OUT);
        // if (pair != 0x0000000000000000000000000000000000000000) {
        //     router.swapExactTokensForTokens(
        //         amount,
        //         0,
        //         getPath(token),
        //         receiver,
        //         block.timestamp
        //     );
        // }
    }

	// function to pack coupon data into abi and calculate hash
	function packCoupon(
		address receiver,
		uint256 amount,
		uint256 nonce,
		uint256 chainId,
		address contractAddress
	) public pure returns (bytes memory) {
		return abi.encode(
			receiver,
			amount,
			nonce,
			chainId,
			contractAddress
		);
	}
	function couponHash(
		address receiver,
		uint256 amount,
		uint256 nonce,
		uint256 chainId,
		address contractAddress
	) public pure returns (bytes32) {
		return keccak256(
			packCoupon(
				receiver,
				amount,
				nonce,
				chainId,
				contractAddress
			)
		);
	}
	function couponHash(
		address receiver,
		uint256 amount,
		uint256 nonce
	) public view returns (bytes32) {
		uint chainId;
		assembly {
			chainId := chainid()
		}
		return couponHash(
			receiver,
			amount,
			nonce,
			chainId,
			address(this)
		);
	}

	// coupon Withdraw event
	event Withdraw(
		address indexed sender,
		address indexed receiver,
		uint256 amount,
		uint256 nonce,
		uint256 chainId,
		address contractAddress
	);

	// coupon signer address with getter and setter
	address couponSigner;
	function getCouponSigner() public view returns (address) {
		return couponSigner;
	}
	function setCouponSigner(address _signer) public {
		require(msg.sender == owner, "only owner");
		couponSigner = _signer;
	}

	function ecrecoverSigned(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns(address) {
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, msgHash));
		return ecrecover(prefixedHash, v, r, s);
	}

	// mapping of user addresses to nonce
	mapping (address => uint256) nonces;

    function withdraw(Coupon calldata coupon, CouponSig calldata sig) external override {

        // // concatenate coupon fields to get the hash
		// bytes32 hash = couponHash(
		// 	coupon.receiver,
		// 	coupon.amount,
		// 	coupon.nonce,
		// 	coupon.chainId,
		// 	coupon.contractAddress
		// );

		// // check signature
		// require(
		// 	ecrecoverSigned(hash, sig.v, sig.r, sig.s) == couponSigner,
		// 	"signature verification failed."
		// );

		// // get receiver nonce
		// uint256 n = nonces[coupon.receiver];

		// // check if the nonce is valid
		// require(
		// 	n == coupon.nonce,
		// 	"invalid nonce."
		// );

		// // update nonce
		// nonces[coupon.receiver] = n + 1;

		// // check if the contract address is valid
		// require(
		// 	coupon.contractAddress == address(this),
		// 	"invalid contract address"
		// );

		// // check if the amount is valid
		// require(
		// 	coupon.amount > 0,
		// 	"invalid amount"
		// );

		// // check if the chainId is valid
		// uint chainId;
		// assembly {
		// 	chainId := chainid()
		// }
		// require(
		// 	coupon.chainId == chainId,
		// 	"invalid chainId"
		// );

		// // transfer the amount from the sender to the receiver
		// require(
		// 	IERC20(TOKEN_OUT).transfer(coupon.receiver, coupon.amount),
		// 	"transfer failed"
		// );

		// emit the event
		emit Withdraw(msg.sender, coupon.receiver, coupon.amount, coupon.nonce, coupon.chainId, coupon.contractAddress);
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