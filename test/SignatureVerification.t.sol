// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SignatureVerification.sol";
import "../src/SimpleToken.sol";

contract SignatureVerificationTest is Test {
    SignatureVerification public signatureVerification;
    SimpleToken public token;

    address public owner = address(0xABCD);
    address public whitelistedUser = address(0x1234);
    address public nonWhitelistedUser = address(0x5678);

    function setUp() public {
        token = new SimpleToken(1000 * 10 ** 18);
        address;
        whitelisted[0] = whitelistedUser;
        signatureVerification = new SignatureVerification(address(token), whitelisted);

        // Transfer tokens to the SignatureVerification contract
        token.transfer(address(signatureVerification), 500 * 10 ** 18);
    }

    function testClaimTokens() public {
        // Whitelisted user should be able to claim tokens
        bytes32 messageHash = keccak256(abi.encodePacked(whitelistedUser));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(whitelistedUser), messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(whitelistedUser); // Simulate the whitelisted user
        signatureVerification.claimTokens(messageHash, signature);

        assertEq(token.balanceOf(whitelistedUser), 100 * 10 ** 18);
    }

    function testFailNonWhitelistedUser() public {
        // Non-whitelisted user should fail
        bytes32 messageHash = keccak256(abi.encodePacked(nonWhitelistedUser));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(nonWhitelistedUser), messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(nonWhitelistedUser);
        signatureVerification.claimTokens(messageHash, signature);
    }
}
