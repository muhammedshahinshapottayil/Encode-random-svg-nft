pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

import {HexStrings} from "./HexStrings.sol";
import {ToColor} from "./ToColor.sol";

contract SVGNFT is ERC721Upgradeable, OwnableUpgradeable {
    error SVGNFT__INVALIDTOKENID();
    error SVGNFT__DONEMINTING();
    error SVGNFT__NFTPRICEHIGHER();

    using Strings for uint256;
    using HexStrings for uint160;
    using ToColor for bytes3;
    uint256 private _tokenIds;

    // all funds go to buidlguidl.eth
    address payable public constant recipient =
        payable(0xa81a6a910FeD20374361B35C451a4a44F86CeD46);

    uint256 public constant limit = 10;
    uint256 public constant curve = 1002; // price increase 0,4% with each purchase
    uint256 public price;
    // the 1154th optimistic loogies cost 0.01 ETH, the 2306th cost 0.1ETH, the 3459th cost 1 ETH and the last ones cost 1.7 ETH

    mapping(uint256 => bytes3) public color;
    mapping(uint256 => uint256) public chubbiness;
    mapping(uint256 => uint256) public mouthLength;

    function initialize() public initializer {
        __ERC721_init("OptimisticLoogies", "OPLOOG");
        __Ownable_init(msg.sender);
        _tokenIds = 1;
        price = 0.001 ether;
        emit Initialized(11111111);
    }

    function mintItem() public payable returns (uint256) {
        uint256 id;
        bytes32 predictableRandom;

        if (_tokenIds > limit) {
            revert SVGNFT__DONEMINTING();
        }

        if (msg.value < price) {
            revert SVGNFT__NFTPRICEHIGHER();
        }

        assembly {
            // Calculate new price: price = (price * curve) / 1000
            let newPrice := div(mul(sload(price.slot), curve), 1000)
            sstore(price.slot, newPrice)

            // Get current _tokenIds and increment
            id := sload(_tokenIds.slot)
            sstore(_tokenIds.slot, add(id, 1))

            // Generate predictableRandom
            mstore(0x00, id)
            mstore(0x20, blockhash(sub(number(), 1)))
            mstore(0x40, caller())
            mstore(0x60, address())
            predictableRandom := keccak256(0x00, 0x80)

            // Set color
            let colorValue := or(
                and(0xFF00, shl(8, byte(0, predictableRandom))),
                or(
                    and(0x00FF, byte(1, predictableRandom)),
                    and(0xFF0000, shl(16, byte(2, predictableRandom)))
                )
            )
            sstore(add(color.slot, id), colorValue)

            // Set chubbiness
            let chubbinessValue := add(
                35,
                div(mul(55, byte(3, predictableRandom)), 255)
            )
            sstore(add(chubbiness.slot, id), chubbinessValue)

            // Set mouthLength
            let mouthLengthValue := add(
                180,
                div(
                    mul(div(chubbinessValue, 4), byte(4, predictableRandom)),
                    255
                )
            )
            sstore(add(mouthLength.slot, id), mouthLengthValue)

            // Transfer value to recipient
            let success := call(
                gas(),
                0xa81a6a910FeD20374361B35C451a4a44F86CeD46,
                callvalue(),
                0,
                0,
                0,
                0
            )
            if iszero(success) {
                // Store the error message
                mstore(0x00, 0x20) // Store offset to error string
                mstore(0x20, 0x0e) // Store length of error string
                mstore(0x40, "could not send") // Store error string
                revert(0x00, 0x60) // Revert with error message
            }
        }

        // The _mint function call is kept outside of assembly as it's likely an internal function
        _mint(msg.sender, id);

        return id;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (ownerOf(id) == address(0)) {
            revert SVGNFT__INVALIDTOKENID();
        }
        string memory name = string(
            abi.encodePacked("Loogie #", id.toString())
        );
        string memory description = string(
            abi.encodePacked(
                "This Loogie is the color #",
                color[id].toColor(),
                " with a chubbiness of ",
                uint2str(chubbiness[id]),
                " and mouth length of ",
                uint2str(mouthLength[id]),
                "!!!"
            )
        );
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"',
                            name,
                            '","description":"',
                            description,
                            '","external_url":"https://burnyboys.com/token/',
                            id.toString(),
                            '","attributes":[',
                            generateAttributes(id),
                            '],"owner":"',
                            uint256(uint160(ownerOf(id))).toHexString(20),
                            '","image":"data:image/svg+xml;base64,',
                            image,
                            '"}'
                        )
                    )
                )
            );
    }

    function generateDescription(
        uint256 id
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "This Loogie is the color #",
                    color[id].toColor(),
                    " with a chubbiness of ",
                    chubbiness[id].toString(),
                    " and mouth length of ",
                    mouthLength[id].toString(),
                    "!!!"
                )
            );
    }

    function generateAttributes(
        uint256 id
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"color","value":"#',
                    color[id].toColor(),
                    '"},',
                    '{"trait_type":"chubbiness","value":',
                    chubbiness[id].toString(),
                    "},",
                    '{"trait_type":"mouthLength","value":',
                    mouthLength[id].toString(),
                    "}"
                )
            );
    }

    function generateSVGofTokenById(
        uint256 id
    ) internal view returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
                '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
                renderTokenById(id),
                "</svg>"
            )
        );

        return svg;
    }

    function renderTokenById(uint256 id) public view returns (string memory) {
        uint256 translateX = (810 - 9 * chubbiness[id]) / 11;

        return
            string(
                abi.encodePacked(
                    '<g id="eye1"><ellipse stroke-width="3" ry="29.5" rx="29.5" cy="154.5" cx="181.5" stroke="#000" fill="#fff"/><ellipse ry="3.5" rx="2.5" cy="154.5" cx="173.5" stroke-width="3" stroke="#000" fill="#000"/></g>',
                    '<g id="head"><ellipse fill="#',
                    color[id].toColor(),
                    '" stroke-width="3" cx="204.5" cy="211.80065" rx="',
                    chubbiness[id].toString(),
                    '" ry="51.80065" stroke="#000"/></g>',
                    '<g id="eye2"><ellipse stroke-width="3" ry="29.5" rx="29.5" cy="168.5" cx="209.5" stroke="#000" fill="#fff"/><ellipse ry="3.5" rx="3" cy="169.5" cx="208" stroke-width="3" fill="#000" stroke="#000"/></g>',
                    '<g class="mouth" transform="translate(',
                    translateX.toString(),
                    ',0)"><path d="M130 240Q165 250 ',
                    mouthLength[id].toString(),
                    ' 235" stroke="#000" stroke-width="3" fill="none"/></g>'
                )
            );
    }
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);

        assembly {
            let position := add(bstr, 32)
            let end := add(position, length)

            for {

            } gt(length, 0) {

            } {
                length := sub(length, 1)
                let remainder := mod(_i, 10)
                mstore8(sub(end, 1), add(remainder, 48))
                _i := div(_i, 10)
                end := sub(end, 1)
            }
        }

        return string(bstr);
    }

    function testGetTokenID() external view returns (uint256) {
        return _tokenIds;
    }

    function getTokenPrice() external view returns (uint256) {
        return price;
    }
}
