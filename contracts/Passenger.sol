pragma solidity ^0.4.17;

contract Passenger {
  address admin;

  function Passenger() public {
    admin = msg.sender;
  }
}
