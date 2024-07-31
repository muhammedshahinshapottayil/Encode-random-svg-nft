pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

import {HexStrings} from "./HexStrings.sol";
import {ToColor} from "./ToColor.sol";

error SVGNFTV2__INVALIDTOKENID();

contract SVGNFTV2 is ERC721Upgradeable, OwnableUpgradeable {
    using Strings for uint256;
    using HexStrings for uint160;
    using ToColor for bytes3;
    uint256 private _tokenIds;

    // all funds go to buidlguidl.eth
    address payable public constant recipient =
        payable(0xa81a6a910FeD20374361B35C451a4a44F86CeD46);

    uint256 public constant limit = 3728;
    uint256 public constant curve = 1002; // price increase 0,4% with each purchase
    uint256 public price = 0.001 ether;
    // the 1154th optimistic loogies cost 0.01 ETH, the 2306th cost 0.1ETH, the 3459th cost 1 ETH and the last ones cost 1.7 ETH

    mapping(uint256 => bytes3) public color;
    mapping(uint256 => uint256) public chubbiness;
    mapping(uint256 => uint256) public mouthLength;
    mapping(uint256 => uint256) public eyeSize;
    mapping(uint256 => bytes3) public eyeColor;

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // reinitializer is not needed or mandatory
    function initialize() public reinitializer(2) {
        emit Initialized(11111111);
    }

    function mintItem() public payable returns (uint256) {
        require(_tokenIds < limit, "DONE MINTING");
        require(msg.value >= price, "NOT ENOUGH");

        price = (price * curve) / 1000;

        uint256 id = _tokenIds;

        _tokenIds += 1;

        _mint(msg.sender, id);

        bytes32 predictableRandom = keccak256(
            abi.encodePacked(
                id,
                blockhash(block.number - 1),
                msg.sender,
                address(this)
            )
        );
        color[id] =
            bytes2(predictableRandom[0]) |
            (bytes2(predictableRandom[1]) >> 8) |
            (bytes3(predictableRandom[2]) >> 16);
        chubbiness[id] =
            35 +
            ((55 * uint256(uint8(predictableRandom[3]))) / 255);
        // small chubiness loogies have small mouth
        mouthLength[id] =
            180 +
            ((uint256(chubbiness[id] / 4) *
                uint256(uint8(predictableRandom[4]))) / 255);
        eyeSize[id] = 20 + ((20 * uint256(uint8(predictableRandom[5]))) / 255);
        eyeColor[id] =
            bytes2(predictableRandom[6]) |
            (bytes2(predictableRandom[7]) >> 8) |
            (bytes3(predictableRandom[8]) >> 16);

        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "could not send");

        return id;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (ownerOf(id) == address(0)) {
            revert SVGNFTV2__INVALIDTOKENID();
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
                ",mouth length of ",
                uint2str(mouthLength[id]),
                ",eye size of ",
                uint2str(eyeSize[id]),
                "and eye color of ",
                eyeColor[id].toColor(),
                "!!!"
            )
        );
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "external_url":"https://burnyboys.com/token/',
                                id.toString(),
                                '", "attributes": [{"trait_type": "color", "value": "#',
                                color[id].toColor(),
                                '"},{"trait_type": "chubbiness", "value": ',
                                uint2str(chubbiness[id]),
                                '},{"trait_type": "mouthLength", "value": ',
                                uint2str(mouthLength[id]),
                                '}], "owner":"',
                                (uint160(ownerOf(id))).toHexString(20),
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '"}'
                            )
                        )
                    )
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

    // Visibility is `public` to enable it being called by other contracts for composition.
    function renderTokenById(uint256 id) public view returns (string memory) {
        // the translate function for the mouth is based on the curve y = 810/11 - 9x/11
        string memory render = string(
            abi.encodePacked(
                '<g id="eye1">',
                '<ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_1" cy="154.5" cx="181.5" stroke="#000" fill="#fff"/>',
                '<ellipse ry="3.5" rx="2.5" id="svg_3" cy="154.5" cx="173.5" stroke-width="3" stroke="#000" fill="#000000"/>',
                "</g>",
                '<g id="head">',
                '<ellipse fill="#',
                color[id].toColor(),
                '" stroke-width="3" cx="204.5" cy="211.80065" id="svg_5" rx="',
                chubbiness[id].toString(),
                '" ry="51.80065" stroke="#000"/>',
                "</g>",
                '<g id="eye2">',
                '<ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_2" cy="168.5" cx="209.5" stroke="#000" fill="#fff"/>',
                '<ellipse ry="3.5" rx="3" id="svg_4" cy="169.5" cx="208" stroke-width="3" fill="#000000" stroke="#000"/>',
                "</g>"
                '<g class="mouth" transform="translate(',
                uint256((810 - 9 * chubbiness[id]) / 11).toString(),
                ',0)">',
                '<path d="M 130 240 Q 165 250 ',
                mouthLength[id].toString(),
                ' 235" stroke="black" stroke-width="3" fill="transparent"/>',
                "</g>"
            )
        );

        return render;
    }

    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
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
