// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/SVGNFT.sol";

contract ImplementationTest is Test {
  SVGNFT public implementation;
  address ADMIN = address(1);
  address USER = address(2);

  function setUp() public {
    vm.startPrank(ADMIN);

    // Deploy and initialize the implementation contract
    implementation = new SVGNFT();
    implementation.initialize();

    vm.stopPrank();
  }

  function testMintItem() public {
    vm.startPrank(USER);
    vm.deal(USER, 1 ether);

    uint256 initialBalance = address(implementation.recipient()).balance;
    uint256 tokenId = implementation.mintItem{ value: 0.001 ether }();

    assertEq(tokenId, 1, "First minted token should have ID 1");
    assertEq(
      implementation.ownerOf(tokenId),
      USER,
      "Minted token should belong to USER"
    );
    assertEq(
      address(implementation.recipient()).balance,
      initialBalance + 0.001 ether,
      "Recipient should receive the payment"
    );

    vm.stopPrank();
  }

  function testTokenURI() public {
    vm.startPrank(USER);
    vm.deal(USER, 1 ether);

    uint256 tokenId = implementation.mintItem{ value: 0.001 ether }();
    string memory uri = implementation.tokenURI(tokenId);
    string memory expectedUri =
      "data:application/json;base64,eyJuYW1lIjoiTG9vZ2llICMxIiwgImRlc2NyaXB0aW9uIjoiVGhpcyBMb29naWUgaXMgdGhlIGNvbG9yICMAAAACAAAgd2l0aCBhIGNodWJiaW5lc3Mgb2YgMCBhbmQgbW91dGggbGVuZ3RoIG9mIDAhISEiLCAiZXh0ZXJuYWxfdXJsIjoiaHR0cHM6Ly9idXJueWJveXMuY29tL3Rva2VuLzEiLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiY29sb3IiLCAidmFsdWUiOiAiIwAAAAIAACJ9LHsidHJhaXRfdHlwZSI6ICJjaHViYmluZXNzIiwgInZhbHVlIjogMH0seyJ0cmFpdF90eXBlIjogIm1vdXRoTGVuZ3RoIiwgInZhbHVlIjogMH1dLCAib3duZXIiOiIweDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDIiLCAiaW1hZ2UiOiAiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpTkRBd0lpQm9aV2xuYUhROUlqUXdNQ0lnZUcxc2JuTTlJbWgwZEhBNkx5OTNkM2N1ZHpNdWIzSm5Mekl3TURBdmMzWm5JajQ4WnlCcFpEMGlaWGxsTVNJK1BHVnNiR2x3YzJVZ2MzUnliMnRsTFhkcFpIUm9QU0l6SWlCeWVUMGlNamt1TlNJZ2NuZzlJakk1TGpVaUlHbGtQU0p6ZG1kZk1TSWdZM2s5SWpFMU5DNDFJaUJqZUQwaU1UZ3hMalVpSUhOMGNtOXJaVDBpSXpBd01DSWdabWxzYkQwaUkyWm1aaUl2UGp4bGJHeHBjSE5sSUhKNVBTSXpMalVpSUhKNFBTSXlMalVpSUdsa1BTSnpkbWRmTXlJZ1kzazlJakUxTkM0MUlpQmplRDBpTVRjekxqVWlJSE4wY205clpTMTNhV1IwYUQwaU15SWdjM1J5YjJ0bFBTSWpNREF3SWlCbWFXeHNQU0lqTURBd01EQXdJaTgrUEM5blBqeG5JR2xrUFNKb1pXRmtJajQ4Wld4c2FYQnpaU0JtYVd4c1BTSWpBQUFBQWdBQUlpQnpkSEp2YTJVdGQybGtkR2c5SWpNaUlHTjRQU0l5TURRdU5TSWdZM2s5SWpJeE1TNDRNREEyTlNJZ2FXUTlJbk4yWjE4MUlpQnllRDBpTUNJZ2NuazlJalV4TGpnd01EWTFJaUJ6ZEhKdmEyVTlJaU13TURBaUx6NDhMMmMrUEdjZ2FXUTlJbVY1WlRJaVBqeGxiR3hwY0hObElITjBjbTlyWlMxM2FXUjBhRDBpTXlJZ2NuazlJakk1TGpVaUlISjRQU0l5T1M0MUlpQnBaRDBpYzNablh6SWlJR041UFNJeE5qZ3VOU0lnWTNnOUlqSXdPUzQxSWlCemRISnZhMlU5SWlNd01EQWlJR1pwYkd3OUlpTm1abVlpTHo0OFpXeHNhWEJ6WlNCeWVUMGlNeTQxSWlCeWVEMGlNeUlnYVdROUluTjJaMTgwSWlCamVUMGlNVFk1TGpVaUlHTjRQU0l5TURnaUlITjBjbTlyWlMxM2FXUjBhRDBpTXlJZ1ptbHNiRDBpSXpBd01EQXdNQ0lnYzNSeWIydGxQU0lqTURBd0lpOCtQQzluUGp4bklHTnNZWE56UFNKdGIzVjBhQ0lnZEhKaGJuTm1iM0p0UFNKMGNtRnVjMnhoZEdVb056TXNNQ2tpUGp4d1lYUm9JR1E5SWswZ01UTXdJREkwTUNCUklERTJOU0F5TlRBZ01DQXlNelVpSUhOMGNtOXJaVDBpWW14aFkyc2lJSE4wY205clpTMTNhV1IwYUQwaU15SWdabWxzYkQwaWRISmhibk53WVhKbGJuUWlMejQ4TDJjK1BDOXpkbWMrIn0=";

    assertTrue(
      keccak256(abi.encodePacked(uri))
        == keccak256(abi.encodePacked(expectedUri)),
      "Token URI incorrect"
    );

    vm.stopPrank();
  }

  function testRenderTokenById() public {
    vm.startPrank(USER);
    vm.deal(USER, 1 ether);

    uint256 tokenId = implementation.mintItem{ value: 0.001 ether }();
    string memory render = implementation.renderTokenById(tokenId);

    assertTrue(bytes(render).length > 0, "The SVG was not properly rendered");

    vm.stopPrank();
  }

  function testInitialTokenId() public view {
    assertEq(implementation.tokenIds(), 1, "Initial tokenId should equal 1");
  }

  function testPriceIncrease() public {
    vm.startPrank(USER);
    vm.deal(USER, 1 ether);

    implementation.mintItem{ value: 0.001 ether }();
    uint256 newPrice = implementation.price();
    vm.stopPrank();

    assertGt(newPrice, 0.001 ether, "Price should increase after minting");
    assertEq(
      newPrice, (0.001 ether * 1002) / 1000, "Price should increase by 0.2%"
    );
  }

  function testMintLimit() public {
    uint256 currentPrice = implementation.price();
    vm.startPrank(USER);
    vm.deal(USER, 10 ether);

    for (uint256 i = 1; i < 11; i++) {
      implementation.mintItem{ value: currentPrice }();
      currentPrice = implementation.price();
    }

    vm.expectRevert();
    implementation.mintItem{ value: currentPrice }();

    vm.stopPrank();
  }

  function testInvalidTokenURI() public {
    vm.expectRevert();
    implementation.tokenURI(2);
  }
}
