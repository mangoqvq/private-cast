import { expect } from "chai";
import { ethers } from "hardhat";
import { PrivateBettingContract } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("PrivateBettingContract", function () {
  async function deployBettingContract() {
    const PrivateBettingContract__factory = await ethers.getContractFactory("PrivateBettingContract");
    const bettingContract = await PrivateBettingContract__factory.deploy("0x636680ec68C513cFBd64e46eB8368a4d40f4248e", "", "");
    await bettingContract.waitForDeployment();
    return { bettingContract };
  }
  let bettingContract: PrivateBettingContract;
  let owner: HardhatEthersSigner;
  let user1: HardhatEthersSigner;
  let user2: HardhatEthersSigner;

  beforeEach(async function () {
    ({ bettingContract } = await deployBettingContract());
    [owner, user1, user2] = await ethers.getSigners();
  });

  it("Should allow a user to place a bet", async function () {
    const betAmount = ethers.parseEther("1"); // 1 Ether

    await bettingContract.connect(user1).placeBet("winner","Charles", "0x636680ec68C513cFBd64e46eB8368a4d40f4248e", "1", "2", ["1", "2", "3", "4", "5", "6", "7", "8"], { value: betAmount });

    const bets = await bettingContract.getAllBets();
    expect(bets.length).to.equal(1);
    expect(bets[0].user).to.equal(user1.address);
    expect(bets[0].amount).to.equal(betAmount);
    expect(bets[0].choice).to.equal("Charles");
    expect(bets[0].settled).to.equal(false);
    const allbets = await bettingContract.getAllBets();
    expect(allbets.length).to.equal(1);
  });

  // it("Should not allow a user to place a bet with zero amount", async function () {
  //   await expect(bettingContract.connect(user1).placeBet("Team A", { value: 0 })).to.be.revertedWith("Bet amount must be greater than zero");
  // });

  // it("Should allow user to settle a bet", async function () {
  //   const betAmount = ethers.parseEther("1");
  //   await bettingContract.connect(user1).placeBet("winner","Charles", "0x636680ec68C513cFBd64e46eB8368a4d40f4248e", "1", "2", ["1", "2", "3", "4", "5", "6", "7", "8"], { value: betAmount });
  //   await bettingContract.connect(owner).setOutcome("winner", "Charles");

  //   // Settle the bet
  //   await bettingContract.connect(user1).settleBet("0", "winner");

  //   const bets = await bettingContract.getAllBets();
  //   expect(bets[0].settled).to.equal(true);

  //   // Check the user's balance to ensure payout was made
  //   const userBalanceAfter = await ethers.provider.getBalance(user1.address);
  //   expect(userBalanceAfter).to.be.gt(Number(ethers.parseEther("100")));
  // });

  // it("Should not allow non-owner to settle a bet", async function () {
  //   const betAmount = ethers.parseEther("1");
  //   await bettingContract.connect(user1).placeBet("Team A", { value: betAmount });

  //   await expect(
  //     bettingContract.connect(user2).settleBet(user1.address, 0, ethers.parseEther("2"))
  //   ).to.be.revertedWith("Only owner can settle bets");
  // });

  // it("Should allow the owner to withdraw the contract balance", async function () {
  //   const betAmount = ethers.parseEther("1");
  //   await bettingContract.connect(user1).placeBet("winner","Charles", "0x636680ec68C513cFBd64e46eB8368a4d40f4248e", "1", "2", ["1", "2", "3", "4", "5", "6", "7", "8"], { value: betAmount });

  //   const initialOwnerBalance = await ethers.provider.getBalance(owner.address);
  //   await bettingContract.connect(owner).withdraw(betAmount);

  //   const newOwnerBalance = await ethers.provider.getBalance(owner.address);
  //   expect(newOwnerBalance).to.be.gt(Number(initialOwnerBalance)); // Owner's balance should increase
  // });

  // it("Should not allow withdrawal by non-owner", async function () {
  //   const betAmount = ethers.parseEther("1");
  //   await bettingContract.connect(user1).placeBet("Team A", { value: betAmount });

  //   await expect(bettingContract.connect(user2).withdraw(betAmount)).to.be.revertedWith("Only owner can withdraw");
  // });
});
