// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../contracts/SVGNFT.sol";
import "../contracts/SVGNFTV2.sol";

contract SVGNFTProxyTest is Test {
    SVGNFT public implementation;
    TransparentUpgradeableProxy public proxy;
    ProxyAdmin public proxyAdmin;
    SVGNFT public proxiedSVGNFT;

    address ADMIN = address(1);
    address USER = address(2);

    function setUp() public {
        vm.startPrank(ADMIN);

        // Deploy the implementation contract
        implementation = new SVGNFT();

        // Deploy the ProxyAdmin
        proxyAdmin = new ProxyAdmin(address(ADMIN));

        // Prepare the initialization data
        bytes memory data = abi.encodeWithSelector(SVGNFT.initialize.selector);

        // Deploy the TransparentUpgradeableProxy
        proxy = new TransparentUpgradeableProxy(
            address(implementation),
            address(proxyAdmin),
            data
        );

        // Create a proxied SVGNFT for easier interaction
        proxiedSVGNFT = SVGNFT(address(proxy));

        vm.stopPrank();
    }

    function testInitianTokenId() public {
        assertEq(
            proxiedSVGNFT.testGetTokenID(),
            1,
            "Initial tokenId should equal 1"
        );
    }

    function testMintItem() public {
        vm.startPrank(USER);
        vm.deal(USER, 1 ether);

        uint256 initialBalance = address(proxiedSVGNFT.recipient()).balance;
        uint256 tokenId = proxiedSVGNFT.mintItem{value: 0.001 ether}();

        assertEq(tokenId, 1, "First minted token should have ID 1");
        assertEq(
            proxiedSVGNFT.ownerOf(tokenId),
            USER,
            "Minted token should belong to USER"
        );
        assertEq(
            address(proxiedSVGNFT.recipient()).balance,
            initialBalance + 0.001 ether,
            "Recipient should receive the payment"
        );

        vm.stopPrank();
    }

    function testPriceIncrease() public {
        vm.startPrank(USER);
        vm.deal(USER, 1 ether);

        proxiedSVGNFT.mintItem{value: 0.001 ether}();
        uint256 newPrice = proxiedSVGNFT.getTokenPrice();
        vm.stopPrank();

        assertGt(newPrice, 0.001 ether, "Price should increase after minting");
        assertEq(
            newPrice,
            (0.001 ether * 1002) / 1000,
            "Price should increase by 0.2%"
        );
    }

    function testMintLimit() public {
        vm.startPrank(USER);
        vm.deal(USER, 10 ether);

        for (uint i = 1; i < 12; i++) {
            uint256 currentPrice = proxiedSVGNFT.getTokenPrice();
            proxiedSVGNFT.mintItem{value: currentPrice}();
        }

        vm.expectRevert(SVGNFT.SVGNFT__DONEMINTING.selector);
        uint256 currentPrice = proxiedSVGNFT.getTokenPrice();
        proxiedSVGNFT.mintItem{value: currentPrice}();

        vm.stopPrank();
    }

    function testTokenURI() public {
        vm.startPrank(USER);
        vm.deal(USER, 1 ether);

        uint256 tokenId = proxiedSVGNFT.mintItem{value: 0.001 ether}();
        string memory uri = proxiedSVGNFT.tokenURI(tokenId);

        assertTrue(bytes(uri).length > 0, "Token URI should not be empty");

        vm.stopPrank();
    }

    function testInvalidTokenURI() public {
        vm.expectRevert(SVGNFT.SVGNFT__INVALIDTOKENID.selector);
        proxiedSVGNFT.tokenURI(999);
    }

    function testUpgrade() public {
        // This test is a placeholder for upgrade functionality
        // You would typically deploy a new implementation and upgrade to it

        SVGNFTV2 svgNFTV2 = new SVGNFTV2();

        vm.prank(address(proxyAdmin));

        ITransparentUpgradeableProxy(address(proxy)).upgradeToAndCall(
            address(svgNFTV2),
            abi.encodeWithSelector(svgNFTV2.initialize.selector)
        );

        // After upgrade, proxiedSVGNFT should still work as expected
        uint256 tokenID = proxiedSVGNFT.testGetTokenID();
        console.log(tokenID);
        assertEq(tokenID, 2, "TokenId should equal 2");
    }
}
