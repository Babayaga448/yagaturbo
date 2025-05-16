// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ScoreClaimer {
    address public owner;
    mapping(address => bool) public claimed;

    constructor() {
        owner = msg.sender;
    }

    // Only owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Owner fund the contract with MON
    receive() external payable {}

    // Users claim reward based on score
    function claim(uint256 score) external {
        require(!claimed[msg.sender], "Already claimed");
        require(score >= 100, "Minimum score is 100");

        uint256 reward = (score / 100) * 0.1 ether; // 0.1 MON per 100 points
        require(address(this).balance >= reward, "Insufficient contract balance");

        claimed[msg.sender] = true;
        (bool sent, ) = msg.sender.call{value: reward}("");
        require(sent, "Transfer failed");
    }

    // Owner can withdraw remaining MON
    function withdraw() external onlyOwner {
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Withdraw failed");
    }
}
