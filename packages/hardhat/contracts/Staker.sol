// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;


    modifier withdrawalDeadlineReached( bool requireReached ) {
    uint256 timeRemaining = withdrawalTimeLeft();
    if( requireReached ) {
      require(timeRemaining == 0, "Withdrawal period is not reached yet");
    } else {
      require(timeRemaining > 0, "Withdrawal period has been reached");
    }
    _;
  }

  modifier claimDeadlineReached( bool requireReached ) {
    uint256 timeRemaining = claimPeriodLeft();
    if( requireReached ) {
      require(timeRemaining == 0, "Claim deadline is not reached yet");
    } else {
      require(timeRemaining > 0, "Claim deadline has been reached");
    }
    _;
  }

  modifier notCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "Stake already completed!");
    _;
  }
  address public whitelisted =  0xfd3fa52ACE486A044b2E156248a3a9B6C3D980E9;

modifier onlyWhitelisted() {
    require(msg.sender == whitelisted , "you cant extract funds");
    _;
  }

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping(address => uint256) public balances; 
mapping(address => uint256) public depositBlockstamps;


uint256 public withdrawalDeadline = block.timestamp + 60 seconds; 
uint256 public claimDeadline = block.timestamp + 120 seconds; 
uint256 public currentBlock = 0;


event Stake(address indexed sender, uint256 amount); 
event Received(address, uint); 
event Execute(address indexed sender, uint256 amount);

  function withdrawalTimeLeft() public view returns (uint256 withdrawalTimeLeft) {
    if( block.timestamp >= withdrawalDeadline) {
      return (0);
    } else {
      return (withdrawalDeadline - block.timestamp);
    }
  }





  function claimPeriodLeft() public view returns (uint256 claimPeriodLeft) {
    if( block.timestamp >= claimDeadline) {
      return (0);
    } else {
      return (claimDeadline - block.timestamp);
    }
  }

 
  function stake() public payable withdrawalDeadlineReached(false) {
    balances[msg.sender] = balances[msg.sender] + msg.value;
    depositBlockstamps[msg.sender] = block.number;
    emit Stake(msg.sender, msg.value);
  }

function killTime() public {
    currentBlock = block.timestamp;
  }
  
  function withdraw() public withdrawalDeadlineReached(true) claimDeadlineReached(false) notCompleted{
    require(balances[msg.sender] > 0, "You have no balance to withdraw!");
    uint256 individualBalance = balances[msg.sender];
    uint256 indBalanceRewards = individualBalance + ((10**18)*((block.number - depositBlockstamps[msg.sender])**2));
    balances[msg.sender] = 0;

    (bool sent, bytes memory data) = msg.sender.call{value: indBalanceRewards}("");
    require(sent, "RIP; withdrawal failed :( ");
  }

  function execute() public claimDeadlineReached(true) notCompleted {
    uint256 contractBalance = address(this).balance;
    exampleExternalContract.complete{value: contractBalance}();
  }

  function resetDeadlines() public onlyWhitelisted {
    
  exampleExternalContract.unlockFunds();

  withdrawalDeadline = block.timestamp + 120 seconds; 
claimDeadline = block.timestamp + 240 seconds; 

  }
  
  receive() external payable {
  emit Received(msg.sender, msg.value);
}

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


}
