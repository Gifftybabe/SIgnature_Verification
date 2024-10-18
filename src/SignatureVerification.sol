// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleToken.sol";

contract SignatureVerification {
    SimpleToken public token;
    address[] public whitelistedAddresses;

    constructor(address _tokenAddress, address[] memory _whitelistedAddresses) {
        token = SimpleToken(_tokenAddress);
        whitelistedAddresses = _whitelistedAddresses;
    }

    function isWhitelisted(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function verifySignature(
        bytes32 messageHash,
        bytes memory signature,
        address signer
    ) public pure returns (bool) {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    function recoverSigner(bytes32 ethSignedMessageHash, bytes memory signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (r, s, v);
    }

    function claimTokens(
        bytes32 messageHash,
        bytes memory signature
    ) public {
        require(isWhitelisted(msg.sender), "Address not whitelisted");
        require(verifySignature(messageHash, signature, msg.sender), "Invalid signature");

        // Transfer tokens to the caller
        require(token.transfer(msg.sender, 100 * 10 ** 18), "Token transfer failed");
    }
}
