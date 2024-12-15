// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


interface IRelayer {
    struct MetaTx {
        address signer;
        address target;
        string message;
        uint256 nonce;
        bytes signature;
        bytes data;
    }

    function send(MetaTx calldata _metaTx) external;

}

