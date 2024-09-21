// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PrivateBettingContract {
    struct Bet {
        address user;
        uint256 amount;
        string topic; // winner for f1
        string choice; // charles, oscar, lando
        bool settled;  // Status of the bet
        uint256 payout; // Amount to be paid out if the bet wins
        uint256 index; // Index of the bet
    }

    address public owner;
    mapping(address => Bet[]) public userBets;
    mapping(address => bool) public verifiedUsers;
    mapping(string => string) public oracleOutcomes; // stores topic -> outcome, e.g. winner -> lando
    address[] public users;

    event BetPlaced(address indexed user, uint256 amount, string choice);
    event BetSettled(address indexed user, uint256 amount, uint256 payout);

    constructor() {
        owner = msg.sender;
    }

    // Function to place a bet
    function placeBet(string memory topic, string memory choice) external payable {
        require(msg.value > 0, "Bet amount must be greater than zero");
        require(bytes(oracleOutcomes[topic]).length == 0, "Outcome is out, cannot bet");
        // Create a new bet
        uint256 index = userBets[msg.sender].length + 1;
        Bet memory newBet = Bet({
            user: msg.sender,
            amount: msg.value,
            topic: topic,
            choice: choice,
            settled: false,
            payout: 0,
            index: index
        });
        userBets[msg.sender].push(newBet);
        users.push(msg.sender);
        emit BetPlaced(msg.sender, msg.value, choice);
    }

    function setOutcome(string memory topic, string memory choice) external {
        require(msg.sender == owner, "Only owner can set oracle data");
        oracleOutcomes[topic] = choice;
    }

    function getOutcome(string memory topic) external view returns (string memory) {
        return oracleOutcomes[topic];
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
    function settleBet(uint256 betIndex, string memory topic) external {
        // Ensure the bet index is valid
        require(betIndex < userBets[msg.sender].length, "Invalid bet index");
        
        // Get the user's bet
        Bet storage bet = userBets[msg.sender][betIndex];
        require(!bet.settled, "Bet already settled");

        // Ensure the oracle outcome is available for the topic
        string memory oracleOutcome = oracleOutcomes[topic];
        require(bytes(oracleOutcome).length > 0, "Oracle outcome not available");

        // Determine if the user's bet matches the oracle outcome
        bool isWinner = keccak256(abi.encodePacked(bet.choice)) == keccak256(abi.encodePacked(oracleOutcome));

        // Calculate the payout
        uint256 payout = 0;
        if (isWinner) {
            payout = bet.amount * 2; // Example payout: 2x the bet amount
        }
        
        // Mark the bet as settled and set the payout
        bet.settled = true;
        bet.payout = payout;

        // Transfer the payout to the user, if any
        if (payout > 0) {
            payable(msg.sender).transfer(payout);
        }

        // Emit an event for logging
        emit BetSettled(msg.sender, bet.amount, payout);
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