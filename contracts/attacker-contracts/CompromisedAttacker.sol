// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../compromised/Exchange.sol";

contract CompromisedAttacker{

    Exchange public immutable exchange;

    constructor(address payable _exchange){
        exchange = Exchange(_exchange);
    }

    function attack() external{

        // cambiar precio del oracle

        uint256 tokenId = exchange.buyOne();

        // devolver precio al oracle
        
        exchange.sellOne(tokenId);
    }

    receive() external payable{

    }
}