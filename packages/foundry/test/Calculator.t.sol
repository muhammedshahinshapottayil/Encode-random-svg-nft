// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../contracts/Calculator.sol";

contract CalculatorTest is Test {
    ProxyAdmin proxyAdmin;
    TransparentUpgradeableProxy proxy;
    Calculator calculator;
    Calculator proxyCalculator;

    function setUp() public {
        // Deploy ProxyAdmin
        address admin = makeAddr("admin");
        proxyAdmin = new ProxyAdmin(admin);

        // Deploy Calculator logic contract
        calculator = new Calculator();

        // Initialize data
        bytes memory data = abi.encodeWithSelector(
            Calculator.initialize.selector
        );

        // Deploy TransparentUpgradeableProxy
        proxy = new TransparentUpgradeableProxy(
            address(calculator),
            address(proxyAdmin),
            data
        );

        // Initialize proxyCalculator to interact with the proxy as a Calculator
        proxyCalculator = Calculator(address(proxy));
    }

    function testAdd() public view {
        uint256 result = proxyCalculator.add(1, 2);
        assertEq(result, 3);
    }

    function testSubtract() public view {
        uint256 result = proxyCalculator.subtract(5, 3);
        assertEq(result, 2);
    }

    function testMultiply() public view {
        uint256 result = proxyCalculator.multiply(4, 5);
        assertEq(result, 20);
    }

    function testDivide() public view {
        uint256 result = proxyCalculator.divide(10, 2);
        assertEq(result, 5);
    }

    function testDivideByZero() public {
        vm.expectRevert("Calculator: division by zero");
        proxyCalculator.divide(10, 0);
    }
}
