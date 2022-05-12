// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;

import "hardhat/console.sol";
import "@uniswap/v2-core/contracts/UniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";

interface IUniswapV2Router02
{
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IERC202 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function deposit() external payable;
    function withdraw(uint wad) external;
}

contract FreeRiderAttacker{

    IUniswapV2Router02 private uniswap;
    address private buyer;
    IERC202 private token;
    IERC202 private weth;
    address private factoryV2;
    UniswapV2Pair private pair;

    constructor(address _uniswap, address _buyer, address _token, address _weth, address _factoryV2, address _pair) public {
        uniswap = IUniswapV2Router02(_uniswap);
        buyer = _buyer;
        token = IERC202(_token);
        weth = IERC202(_weth);
        factoryV2 = _factoryV2;
        pair = UniswapV2Pair(_pair);
    }

    function callUniswap() external{
        bytes memory data = abi.encode("");
        pair.swap(1, 1, address(this), data);
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {
        address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
        address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1
        assert(msg.sender == IUniswapV2Factory(factoryV2).getPair(token0, token1)); // ensure that msg.sender is a V2 pair

        console.log("aaaaaaaaa");
    }

    function receive() external payable {}
}