// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

contract Swirl {

    // Struct to store the details of the privacy pool
    struct PrivacyPool {
        address payable[] depositors; // Addresses that have deposited funds into the pool
        uint256 totalDeposits; // Total amount of ETH deposited into the pool
    }

    PrivacyPool private pool; // Private privacy pool

    // Function to deposit ETH into the privacy pool and generate a Swirl Cash Note
    function deposit(uint256 depositAmount) public payable returns (bytes32) {
        require(msg.value == depositAmount, "Deposit amount must match the specified deposit amount");
        pool.depositors.push(payable(msg.sender));
        pool.totalDeposits += msg.value;
        bytes32 note = keccak256(abi.encodePacked(msg.sender, address(0), msg.value));
        return note;
    }

    // Function to withdraw funds anonymously using a Swirl Cash Note
    function withdraw(bytes32 note, address payable withdrawalAddress,uint256 withdrawAmount) public payable {
        bool validNote = false;
        uint256 noteValue = 0;
        for (uint i = 0; i < pool.depositors.length; i++) {
            address payable depositor = pool.depositors[i];
            bytes32 depositorNote = keccak256(abi.encodePacked(depositor, address(0),withdrawAmount));
            if (depositorNote == note) {
                validNote = true;
                noteValue = withdrawAmount;
                pool.totalDeposits -= withdrawAmount;
                depositor.transfer(withdrawAmount);
                break;
            }
        }
        require(validNote, "Invalid Swirl Cash Note");
        withdrawalAddress.transfer(noteValue);
    }
}
