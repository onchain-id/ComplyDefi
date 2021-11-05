// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IComplyDeFi {

    /// event emitted when a new issuer is added
    event TrustedIssuerAdded(address issuer, uint[] claimTopics);
    /// event emitted when an existing issuer is updated
    event TrustedIssuerUpdated(address issuer, uint[] claimTopics);
    /// event emitted when trust is revoked for an issuer
    event TrustedIssuerRemoved(address issuer);
    /// event emitted when a claim requirement is added
    event ClaimRequired(uint claimTopic);
    /// event emitted when a claim requirement is removed
    event ClaimUnRequired(uint claimTopic);
    /// event emitted when the factory address is set
    event FactorySet(address _factory);

    function setFactory(address _factory) external;

    function isTrustedIssuer(address _wallet) external view returns (bool);

    function addTrustedIssuer(address _issuer, uint[] memory _claimTopics) external;

    function removeTrustedIssuer(address _issuer) external;

    function updateIssuerTopics(address _issuer, uint[] memory _claimTopics) external;

    function isClaimRequired(uint _claim) external view returns (bool);

    function addRequiredClaim(uint _claim) external;

    function removeRequiredClaim(uint _claim) external;

    function hasClaimTopic(address _issuer, uint _claimTopic) external view returns (bool);

    function isComply(address _user) external view returns (bool);


}
