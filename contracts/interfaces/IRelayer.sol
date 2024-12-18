// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


interface IRelayer {
    struct MetaTx {
        address from;
        address to;
        bytes data;
        uint256 nonce;
        uint256 deadline;
    }

    function send(MetaTx calldata _metaTx, bytes calldata signature) external;

}

