// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dummy {
    constructor() {}

    // Event declaration with the number to be emitted
    event NumberReceived(uint256 indexed number);

    // Function to receive a number and emit an event
    function submitNumber(uint256 _number) public {
        // Emit the event with the received number
        emit NumberReceived(_number);
    }

    // Optional function to get the last submitted number (if needed)
    uint256 public lastNumber;

    // Function that updates and stores the last number along with emitting the event
    function updateAndEmitNumber(uint256 _number) public returns (uint256) {
        // Store the number
        lastNumber = _number;
        
        // Emit the event
        emit NumberReceived(_number);
        return _number;
    }
}