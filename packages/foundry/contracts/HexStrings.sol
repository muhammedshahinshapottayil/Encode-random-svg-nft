// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

library HexStrings {
  bytes16 private constant ALPHABET = "0123456789abcdef";

  function toHexString(
    uint256 value,
    uint256 length
  ) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";

    assembly {
      let pos := add(buffer, 34)
      let end := add(pos, mul(length, 2))
      let remaining := value

      for { } lt(pos, end) { } {
        mstore8(sub(end, 1), byte(mod(remaining, 16), ALPHABET))
        remaining := div(remaining, 16)
        end := sub(end, 1)
      }
    }

    return string(buffer);
  }
}
