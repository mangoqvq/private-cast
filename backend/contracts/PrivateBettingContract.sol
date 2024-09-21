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
    mapping(address => Bet[]) public userBets;
    mapping(address => bool) public verifiedUsers;
    address[] public users;
    event BetPlaced(address indexed user, uint256 amount, string choice);
    event BetSettled(address indexed user, uint256 amount, uint256 payout);

    constructor() {
        owner = msg.sender;
    }

    // Function to place a bet
    function placeBet(string memory choice) external payable {
        require(msg.value > 0, "Bet amount must be greater than zero");
        // require(verifiedUsers[msg.sender], "You must be a verified user to place a bet");
        // Create a new bet
        Bet memory newBet = Bet({
            user: msg.sender,
            amount: msg.value,
            choice: choice,
            settled: false,
            payout: 0
        });
        userBets[msg.sender].push(newBet);
        users.push(msg.sender);
        emit BetPlaced(msg.sender, msg.value, choice);
    }

    // Function to get bets of a user
    function getBets(address user) external view returns (Bet[] memory) {
        return userBets[user];
    }

    function getAllBets() external view returns (Bet[] memory) {
        uint256 totalBets = 0;
        for (uint256 i = 0; i < users.length; i++) {
            totalBets += userBets[users[i]].length;
        }

        Bet[] memory allBets = new Bet[](totalBets);
        uint256 index = 0;
        
        for (uint256 i = 0; i < users.length; i++) {
            Bet[] memory userBetsArray = userBets[users[i]];
            for (uint256 j = 0; j < userBetsArray.length; j++) {
                allBets[index] = userBetsArray[j];
                index++;
            }
        }
        return allBets;
    }
    
    // Function to settle a bet and distribute payout
    function settleBet(address user, uint256 betIndex, uint256 payout) external {
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