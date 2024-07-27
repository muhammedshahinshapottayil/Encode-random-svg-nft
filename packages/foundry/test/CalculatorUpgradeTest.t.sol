// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../contracts/Calculator.sol";
import "../contracts/CalculatorV2.sol";

contract CalculatorUpgradeTest is Test {
    TransparentUpgradeableProxy proxy;
    Calculator calculator;
    CalculatorV2 calculatorV2;

    function setUp() public {
        address admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        // Deploy Calculator logic contract
        calculator = new Calculator();

        // Initialize data
        bytes memory data = abi.encodeWithSelector(
            Calculator.initialize.selector
        );

        // Deploy TransparentUpgradeableProxy
        proxy = new TransparentUpgradeableProxy(
            address(calculator),
            admin,
            data
        );
    }

    function testUpgradeToCalculatorV2() public {
        // Deploy CalculatorV2 logic contract
        calculatorV2 = new CalculatorV2();

        // Set the caller to the ProxyAdmin
        // this is the address of the deployed ProxyAdmin from the TransparentUpgradeableProxy contract
        address adminProxy = 0xffD4505B3452Dc22f8473616d50503bA9E1710Ac;

        vm.prank(adminProxy);

        ITransparentUpgradeableProxy(address(proxy)).upgradeToAndCall(
            address(calculatorV2),
            abi.encodeWithSelector(calculatorV2.initialize.selector , "Test")
        );

        // Interact with proxy using CalculatorV2 functions
        CalculatorV2 proxyCalculatorV2 = CalculatorV2(address(proxy));
        uint256 result = proxyCalculatorV2.mod(10, 3);
        assertEq(result, 1);

        string memory text = proxyCalculatorV2.testSring();
        assertEq(text, "Test");
    }
}
