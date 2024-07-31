// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract CalculatorV2 is Initializable {

    string public testSring;

    function initialize(string calldata _string) external {
        testSring = _string;
    }

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        return a - b;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Calculator: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "CalculatorV2: division by zero");
        return a % b;
    }
}
