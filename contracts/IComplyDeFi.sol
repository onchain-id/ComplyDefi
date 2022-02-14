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

    /**
     *  @dev setter for the ONCHAINID Factory address
     *  can be used post-deployment to update the ONCHAINID Factory address if required
     *  OnlyOwner function : the owner wallet is the only one able to call this function
     *  @param _factory the address of the ONCHAINID factory
     *  emits a `FactorySet` event
     */
    function setFactory(address _factory) external;

    /**
     *  @dev getter for the trusted status of a claim issuer
     *  returns true if the address corresponds to a trusted issuer and false if not
     *  public function : can be called by anyone
     *  @param _issuer the address of the ONCHAINID contract of the claim issuer
     *  it is important to note that the _issuer address here is not a wallet address but an ONCHAINID
     */
    function isTrustedIssuer(address _issuer) external view returns (bool);

    /**
     *  @dev function used to add a new trusted issuer for the contract
     *  adds a trusted issuer and the corresponding claims they are trusted for
     *  can be called only to register a new claim issuer, to update an existing issuer,
     *  please use the `updateIssuerTopics` function
     *  onlyOwner function : the owner wallet is the only one able to call this function
     *  @param _issuer the address of the ONCHAINID contract of the claim issuer
     *  @param _claimTopics the array of claim topics for which the issuer is trusted
     *  it is important to note that the _issuer address here is not a wallet address but an ONCHAINID
     *  emits a `TrustedIssuerAdded` event
     */
    function addTrustedIssuer(address _issuer, uint[] memory _claimTopics) external;

    /**
     *  @dev function used to remove the trusted status from a claim issuer
     *  removes the trusted status of an existing claim issuer
     *  can be called only to remove an existing claim issuer, function call will fail
     *  if the issuer does not exist
     *  onlyOwner function : the owner wallet is the only one able to call this function
     *  @param _issuer the address of the ONCHAINID contract of the claim issuer
     *  it is important to note that the _issuer address here is not a wallet address but an ONCHAINID
     *  emits a `TrustedIssuerRemoved` event
     */
    function removeTrustedIssuer(address _issuer) external;

    /**
     *  @dev function used to update the claim set that a claim issuer is trusted for
     *  can be called only on an existing claim issuer, function call will fail
     *  if the issuer does not exist
     *  the set of claim topics cannot be empty, otherwise the issuer is not considered as trusted anymore
     *  in this case use the function `removeTrustedIssuer` instead
     *  onlyOwner function : the owner wallet is the only one able to call this function
     *  @param _issuer the address of the ONCHAINID contract of the claim issuer
     *  @param _claimTopics the array of claim topics for which the issuer is trusted
     *  it is important to note that the _issuer address here is not a wallet address but an ONCHAINID
     *  emits a `TrustedIssuerUpdated` event
     */
    function updateIssuerTopics(address _issuer, uint[] memory _claimTopics) external;

    /**
     *  @dev view function used to check if a claim is required or not to be eligible on the contract
     *  returns true if the claim is required and false otherwise
     *  public function : can be called by anyone
     *  @param _claim the claim topic that is currently checked
     */
    function isClaimRequired(uint _claim) external view returns (bool);

    /**
     *  @dev function used to add a claim topic to the list of claim topics
     *  that are required to be considered eligible by the contract
     *  onlyOwner function : the owner wallet is the only one able to call this function
     *  @param _claim the claim topic that has to be added
     *  emits a `ClaimRequired` event
     */
    function addRequiredClaim(uint _claim) external;

    /**
     *  @dev function used to remove a claim topic to the list of claim topics
     *  that are required to be considered eligible by the contract
     *  onlyOwner function : the owner wallet is the only one able to call this function
     *  @param _claim the claim topic that has to be removed
     *  emits a `ClaimUnRequired` event
     */
    function removeRequiredClaim(uint _claim) external;

    /**
     *  @dev function used to check if an issuer is trusted for a specific claim topic
     *  public function : can be called by anyone
     *  @param _issuer the claim issuer contract
     *  @param _claimTopic the claim topic that is checked
     *  returns true if the issuer has this claim and false otherwise
     *  it is important to note that the _issuer address here is not a wallet address but an ONCHAINID
     */
    function hasClaimTopic(address _issuer, uint _claimTopic) external view returns (bool);

    /**
     *  @dev function used to check if a wallet is eligible following the requirements of the contract
     *  public function : can be called by anyone
     *  @param _user the wallet address of the user
     *  returns true if the wallet is eligible and false otherwise
     *  this function is basically checking if the wallet is linked to an eligible ONCHAINID contract
     *  and if this ONCHAINID contains the required claim topics emitted by the issuers that are trusted
     *  for the topics
     */
    function isComply(address _user) external view returns (bool);


}
