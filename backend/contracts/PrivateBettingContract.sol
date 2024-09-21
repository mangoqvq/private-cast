// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PrivateBettingContract {
    struct Bet {
        address user;
        uint256 amount;
        string choice; // The user's betting choice
        bool settled;  // Status of the bet
        uint256 payout; // Amount to be paid out if the bet wins
    }

    address public owner;
    mapping(address => Bet[]) public userBets; // Mapping of user address to their bets

    // Events for logging
    event BetPlaced(address indexed user, uint256 amount, string choice);
    event BetSettled(address indexed user, uint256 amount, uint256 payout);
    event Debug(string message, address user, uint256 betIndex, uint256 payout);

    constructor() {
        owner = msg.sender; // Set the owner of the contract
    }

    // Function to place a bet
    function placeBet(string memory choice) external payable {
        require(msg.value > 0, "Bet amount must be greater than zero");

        // Create a new bet
        Bet memory newBet = Bet({
            user: msg.sender,
            amount: msg.value,
            choice: choice,
            settled: false,
            payout: 0
        });

        // Store the bet in the user's bet array
        userBets[msg.sender].push(newBet);

        // Emit BetPlaced event
        emit BetPlaced(msg.sender, msg.value, choice);
    }

    // Function to get bets of a user
    function getBets(address user) external view returns (Bet[] memory) {
        return userBets[user];
    }

    // Function to settle a bet and distribute payout
    function settleBet(address user, uint256 betIndex, uint256 payout) external {
        emit Debug("Settling bet", user, betIndex, payout);
        require(msg.sender == owner, "Only owner can settle bets");
        require(betIndex < userBets[user].length, "Invalid bet index");
        
        Bet storage bet = userBets[user][betIndex];
        require(!bet.settled, "Bet already settled");
        
        bet.settled = true;
        bet.payout = payout;

        // Transfer the payout to the user
        if (payout > 0) {
            payable(user).transfer(payout);
        }

        // Emit BetSettled event
        emit BetSettled(user, bet.amount, payout);
    }

    // Function to withdraw the owner's balance (optional)
    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance >= amount, "Insufficient balance");
        
        payable(owner).transfer(amount);
    }

    // Function to get the contract balance (optional)
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}