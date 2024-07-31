// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

/**
 * @title Color Conversion Library for SVG Generator based on ERC-4883
 */
library ToColor {
  function toColor(bytes3 value) internal pure returns (string memory) {
    bytes memory buffer = new bytes(6);

    assembly {
      let pos := add(buffer, 32)

      // Convert first byte
      mstore8(pos, byte(28, mload(add(value, 32))))
      mstore8(add(pos, 1), byte(29, mload(add(value, 32))))

      // Convert second byte
      mstore8(add(pos, 2), byte(30, mload(add(value, 32))))
      mstore8(add(pos, 3), byte(31, mload(add(value, 32))))

      // Convert third byte
      mstore8(add(pos, 4), byte(0, mload(add(value, 33))))
      mstore8(add(pos, 5), byte(1, mload(add(value, 33))))
    }

    return string(buffer);
  }
}
