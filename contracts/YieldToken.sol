//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IRobos} from "./Interface/IRobos.sol";


contract YieldToken is ERC20("Robo Token", "RBTK") {


/*/////////////////////////////////////////////////////////////
                      Public Vars
/////////////////////////////////////////////////////////////*/


    uint256 constant public BASE_RATE = 2 ether; 

    uint256 constant public JR_BASE_RATE = 1 ether;

    //INITAL_ISSUANCE off of mintint a ROBO
    uint256 constant public INITAL_ISSUANCE = 5 ether; 
    /// End time for Base rate yeild token (UNIX timestamp)
    /// END time = Sun Jan 30 2033 01:01:01 GMT-0700 (Mountain Standard Time) - in 11 years
    uint256 constant public END = 1959062461; 
    

/*/////////////////////////////////////////////////////////////
                        Mappings
/////////////////////////////////////////////////////////////*/

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastUpdate;

    IRobos public robosContract;

/*/////////////////////////////////////////////////////////////
                        Events
/////////////////////////////////////////////////////////////*/

    event RewardPaid(address indexed user, uint256 reward);

/*/////////////////////////////////////////////////////////////
                      Constructor
/////////////////////////////////////////////////////////////*/

    constructor(address _robos) {
        robosContract = IRobos(_robos);
    }


/*/////////////////////////////////////////////////////////////
                  Internal Functions
/////////////////////////////////////////////////////////////*/

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
      return a < b ? a : b;
    }

/*/////////////////////////////////////////////////////////////
                    External Functions
/////////////////////////////////////////////////////////////*/


    // function updateRewardOnMint(address _user, uint256 _amount) external {
    //   require(msg.sender == address(robosContract), "Cant call this");
    //   uint256 time = min(block.timestamp, END);
    //   uint256 timerUser = lastUpdate[_user];
    //   if (timerUser > 0 ) {
    //       //@TODO
    //   }
    // }


    // function updageReward(address _from, address _to, uint256 _tokenId) external {
    //   require(msg.sender == address(robosContract));
    //   if (_tokenId < 5001) {
    //     uint256 time = min(block.timestamp, END);
    //     uint256 timerFrom = lastUpdate[_from];
        
    //     if (timerFrom > 0) 
    //       rewards[_from] += robosContract.balanceOG(_from) * (BASE_RATE * (time - timerFrom)) / 86400;
        
    //     if (timerFrom != END) 
    //       lastUpdate[_from] = time;
        
    //     if (_to != address(0)) {
    //       uint256 timerTo = lastUpdate[_to];
    //       if (timerTo > 0) 
    //         rewards[_to] += robosContract.balanceOG(_to) * (BASE_RATE * (time - timerTo)) / 86400;
    //       if (timerTo != END) 
    //         lastUpdate[_to] = time;
    //     }
    //   }
    //   if (_tokenId >= 5001) {
    //     uint256 time = min(block.timestamp, END);
    //     uint256 timerFrom = lastUpdate[_from];
                
    //     if (timerFrom > 0) 
    //       rewards[_from] += robosContract.balanceOG(_from) * (JR_BASE_RATE * (time - timerFrom)) / 86400;
        
    //     if (timerFrom != END) 
    //       lastUpdate[_from] = time;

    //     if (_to != address(0)) {
    //       uint256 timerTo = lastUpdate[_to];
    //       if (timerTo > 0) 
    //         rewards[_to] += robosContract.balanceOG(_to) * (JR_BASE_RATE * (time - timerTo)) / 86400;
    //       if (timerTo != END) 
    //         lastUpdate[_to] = time;
    //     }
    //   }
    // }


    // function getReward(address _to) external {
    //   require(msg.sender == address(robosContract));
    //   uint256 reward = rewards[_to];
    //   if (reward > 0) {
    //     rewards[_to] = 0;
    //     _mint(_to, reward);
    //     emit RewardPaid(_to, reward);
    //   }
    // }

    function burn(address _from, uint256 _amount) external {
      require(msg.sender == address(robosContract));
      _burn(_from, _amount);
    }

    // function getTotalClaimable(address _user) external view returns(uint256) {
    //   uint256 time = min(block.timestamp, END);
    //   uint256 pending = robosContract.balanceOG(_user) * ((BASE_RATE * (time - lastUpdate[_user])) / 86400);
    //   return rewards[_user] + pending;
    // }
/*/////////////////////////////////////////////////////////////
                  onlyOwner Functions
/////////////////////////////////////////////////////////////*/

}

