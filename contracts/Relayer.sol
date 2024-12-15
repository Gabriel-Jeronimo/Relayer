// SPDX-License-Identifier: UNLICENSED
import "./interfaces/IRelayer.sol";
import "hardhat/console.sol";
pragma solidity ^0.8.28;

// TODO: Add a deadline to the metaTx
contract Relayer is IRelayer {
    constructor() {}

    function send(MetaTx calldata _metaTx) external override {}
}


