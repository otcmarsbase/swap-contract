// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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
