// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  event Stake(address,uint256);
  uint256 public deadline = block.timestamp + 30 seconds;
  bool openForWithdraw;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }


  modifier notCompleted() {
    require(!exampleExternalContract.completed());
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() payable public{
    balances[msg.sender] = msg.value;
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() external notCompleted{
    require(block.timestamp > deadline);
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }else{
      openForWithdraw = true;
    }
    

  }


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() external notCompleted{
    require(openForWithdraw, "you can't widthraw your funds");
    (bool succes, ) = msg.sender.call{ value: address(this).balance }("");
    require(succes);
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() view external returns(uint256){
    if(block.timestamp < deadline){
      return deadline - block.timestamp;
    }else{
      return 0;
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() payable external{
    stake();
  }

}
