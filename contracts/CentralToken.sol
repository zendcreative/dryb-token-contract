pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';


contract CentralToken is StandardToken {
  address owner;

  function CentralToken() public {
    owner = msg.sender;
  }

}
