// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract ExampleExternalContract {

  

  bool public completed;
  address contractAddress;

  function complete() public payable {
    completed = true;
    contractAddress = msg.sender;
  }

  function unlockFunds () public {
    require(msg.sender == contractAddress , "you cant extract funds");
    completed = false;
    contractAddress.call{value: address(this).balance}("");
  }

}
