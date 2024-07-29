//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/SVGNFT.sol";
import "./DeployHelpers.s.sol";
import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }

        address admin = vm.envAddress("ADMIN_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        //Deploy SVG Contract
        SVGNFT nftContract = new SVGNFT();

        console.logString(
            string.concat(
                "The new SVG Contract deployed at: ",
                vm.toString(address(nftContract))
            )
        );

        // Initialize data
        bytes memory data = abi.encodeWithSelector(
            nftContract.initialize.selector
        );

        // Deploy TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(nftContract),
            admin,
            data
        );

        console.logString(
            string.concat(
                "The new proxy Contract deployed at: ",
                vm.toString(address(proxy))
            )
        );

        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }
}
