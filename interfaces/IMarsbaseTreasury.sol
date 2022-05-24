// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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