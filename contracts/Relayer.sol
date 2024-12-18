// SPDX-License-Identifier: UNLICENSED
import "./interfaces/IRelayer.sol";
import "hardhat/console.sol";
pragma solidity ^0.8.28;



import "@openzeppelin/contracts/access/Ownable.sol";



contract Relayer is IRelayer, Ownable {
    address private _owner;

    constructor() Ownable(msg.sender) {}

    mapping(address => uint256) addressToNonce;
    mapping(address => bool) _isTargetPermited;

    modifier isTargetPermited(address target) {
        require(_isTargetPermited[target], "Target doesnt have permission");
        _;
    }
    
    function send(MetaTx calldata _metaTx, bytes calldata _signature) external override {
        require(_metaTx.nonce == addressToNonce[_metaTx.from] + 1, "Invalid nonce");
        require(block.timestamp <= _metaTx.deadline, "Meta transaction expired");

        require(_verify(_metaTx.from, _metaTx.to, _metaTx.data, _metaTx.nonce, _signature), "Signature invalid");
    
        addressToNonce[_metaTx.from] = _metaTx.nonce; 
    
        // Actually execute the transaction to the target contract
        (bool success, ) = _metaTx.to.call(_metaTx.data);
        require(success, "Transaction execution failed");
    }

    function giveTargetPermission(address target) external  {
        _isTargetPermited[target] = true;
    }

    function revokeTargetPermission(address target) external  {
        _isTargetPermited[target] = false;
    }


    function getMessageHash(
        address _to,
        address _from,
        bytes memory _data,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _from, _data, _nonce));
    }

    function _verify(address _from, address _to, bytes memory _data, uint256 _nonce, bytes memory _signature) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _from, _data, _nonce);
        address recoveredSignature = _recoverSignature(messageHash, _signature);

        return recoveredSignature == _from;
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


