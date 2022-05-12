require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require('hardhat-dependency-compiler');
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-ethers");

module.exports = {
    networks: {
      hardhat: {
        allowUnlimitedContractSize: true
      }  
    },
    solidity: {
      compilers: [
        { version: "0.8.7" },
        { version: "0.7.6" },
        { version: "0.6.6" },
        { version: "0.5.16" }
      ]
    },
    dependencyCompiler: {
      paths: [
        '@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol',
        '@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol',
      ],
    }
}
