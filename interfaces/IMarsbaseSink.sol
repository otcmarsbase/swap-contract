// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IMarsbaseSink {
    function takeAndSwap(
        address from,
        address token,
        uint256 amount,
        address receiver
    ) external;
}