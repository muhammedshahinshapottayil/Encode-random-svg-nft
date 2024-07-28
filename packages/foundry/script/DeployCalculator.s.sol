// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../contracts/Calculator.sol";

contract DeployCalculatorScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address admin = vm.envAddress("ADMIN_ADDRESS");

        // Deploy Calculator logic contract
        Calculator calculator = new Calculator();

        // Initialize data
        bytes memory data = abi.encodeWithSelector(
            Calculator.initialize.selector
        );

        // Deploy TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(calculator),
            admin,
            data
        );

        vm.stopBroadcast();

        // Log addresses
        console.log(
            "Calculator logic contract deployed to:",
            address(calculator)
        );
        console.log("TransparentUpgradeableProxy deployed to:", address(proxy));
    }
}
