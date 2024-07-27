//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/svgNFT.sol";
import "./DeployHelpers.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);
    SVGNFT nftContract;

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);

        nftContract = new SVGNFT();
        console.logString(
            string.concat(
                "The new SVG Contract deployed at: ",
                vm.toString(address(nftContract))
            )
        );

        uint256 nftPrice = nftContract.price();

        mintNFT(nftPrice);

        nftContract = new SVGNFT();

        Deployment memory newContractDeployed = Deployment(
            "SVGNFT",
            address(nftContract)
        );

        deployments.push(newContractDeployed);

        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function mintNFT(uint256 _nftPrice) public {
        uint256 tokenID = nftContract.mintItem{value: _nftPrice}();
        console.log("@@@tokenID", tokenID);
    }
}
