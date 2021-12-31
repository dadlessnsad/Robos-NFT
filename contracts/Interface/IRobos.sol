//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IRobos {
  function balanceOG(address _user) external view returns(uint256);

  function jrCount(address _user) external view returns(uint256);
}