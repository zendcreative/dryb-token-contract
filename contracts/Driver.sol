pragma solidity ^0.4.17;


contract Driver {
  address admin;

  function Driver() public {
    admin = msg.sender;
  }
}
