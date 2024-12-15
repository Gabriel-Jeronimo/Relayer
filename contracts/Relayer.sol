// SPDX-License-Identifier: UNLICENSED
import "./interfaces/IRelayer.sol";
import "hardhat/console.sol";
pragma solidity ^0.8.28;

// TODO: Add a deadline to the metaTx
contract Relayer is IRelayer {
    constructor() {}

    mapping(address => uint256) addressToNonce;

    function send(MetaTx calldata _metaTx) external override {
        console.log("%d", _metaTx.nonce);
        console.log("%s", _metaTx.signer);

        require(addressToNonce[_metaTx.signer] == _metaTx.nonce + 1, "Invalid nonce");

        require(_verify(_metaTx.signer, _metaTx.target, _metaTx.data, _metaTx.nonce, _metaTx.signature));
    
        addressToNonce[_metaTx.signer] = _metaTx.nonce;
    
        // Actually execute the transaction
        (bool success, ) = _metaTx.target.call(_metaTx.data);
        require(success, "Transaction execution failed");
    }

    function _verify(address _signer, address _target, bytes memory _data, uint256 _nonce, bytes memory _signature) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_target, _signer, _data, _nonce);
        bytes32 signedMessage = _getSignedMessage(messageHash);

        return _recoverSignature(signedMessage, _signature) == _signer;
    }

    function getMessageHash(
        address _target,
        address _signer,
        bytes memory _data,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_target, _signer, _data, _nonce));
    }


    function _getSignedMessage(bytes32 _messageHash) internal pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256| hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */

        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function _recoverSignature(bytes32 _message, bytes memory _signature) internal pure returns (address) {
        bytes32 signedMessage = _getSignedMessage(_message); 
        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(_signature);

        return ecrecover(signedMessage, v, r, s);
    }

    function _splitSignature(
        bytes memory sig
    ) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65);

        // Stores the signature
        uint8 v;
        // Stores the hashed data
        bytes32 r;
        bytes32 s;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}


