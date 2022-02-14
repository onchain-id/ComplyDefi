// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IComplyDeFi.sol";
import "./factory/IIdFactory.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '@onchain-id/solidity/contracts/interface/IClaimIssuer.sol';


contract ComplyDeFi is IComplyDeFi, Ownable {

    /// address of the ONCHAINID Factory contract
    address public factory;
    /// ONCHAINID linked to the complyDeFi contract
    address public complyDeFiID;

    /// claims required to validate a pattern
    uint[] public requiredClaims;
    /// correspondence table linking trusted issuers and the claim topics they are trusted for
    mapping(address => uint[]) public trustedIssuerClaims;



    // modifier checking the compliance status of the wallet calling the transaction
    // this modifier has to be put on each function that requires a compliance check
    modifier onlyComply() {
        require(isComply(msg.sender), 'ComplyDeFi : caller not compliant');
        _;
    }

    /**
     *  @dev Constructor of the ComplyDeFi contract
     *  insert this constructor in the constructor of your DeFi app inheriting ComplyDeFi
     *  @param _factory the address of the ONCHAINID factory
     *  @param _id the address of the ONCHAINID of the DeFi protocol implementing ComplyDeFi
     */
    constructor (address _factory, address _id) {
        factory = _factory;
        complyDeFiID = _id;
    }

    /**
     *  @dev See {IComplyDeFi-setFactory}.
     */
    function setFactory(address _factory) external override onlyOwner {
        factory = _factory;
        emit FactorySet(_factory);
    }

    /**
     *  @dev See {IComplyDeFi-isTrustedIssuer}.
     */
    function isTrustedIssuer(address _issuer) public view override returns (bool){
        if (trustedIssuerClaims[_issuer].length > 0) {
            return true;
        }
        return false;
    }

    /**
     *  @dev See {IComplyDeFi-addTrustedIssuer}.
     */
    function addTrustedIssuer(address _issuer, uint[] memory _claimTopics) external override onlyOwner {
        require(!isTrustedIssuer(_issuer), "issuer already exists");
        trustedIssuerClaims[_issuer] = _claimTopics;
        emit TrustedIssuerAdded(_issuer, _claimTopics);
    }

    /**
     *  @dev See {IComplyDeFi-removeTrustedIssuer}.
     */
    function removeTrustedIssuer(address _issuer) external override onlyOwner {
        require(isTrustedIssuer(_issuer), "issuer doesn't exists");
        delete trustedIssuerClaims[_issuer];
        emit TrustedIssuerRemoved(_issuer);
    }

    /**
     *  @dev See {IComplyDeFi-updateIssuerTopics}.
     */
    function updateIssuerTopics(address _issuer, uint[] memory _claimTopics) external override onlyOwner {
        require(isTrustedIssuer(_issuer), "issuer doesn't exists");
        require(_claimTopics.length > 0 , "claim set cannot be empty");
        trustedIssuerClaims[_issuer] = _claimTopics;
        emit TrustedIssuerUpdated(_issuer, _claimTopics);
    }

    /**
     *  @dev See {IComplyDeFi-isClaimRequired}.
     */
    function isClaimRequired(uint _claim) public view override returns (bool) {
        uint length = requiredClaims.length;
        for (uint i = 0; i < length; i++) {
            if (requiredClaims[i] == _claim) {
                return true;
            }
        }
        return false;
    }

    /**
     *  @dev See {IComplyDeFi-addRequiredClaim}.
     */
    function addRequiredClaim(uint _claim) external override onlyOwner {
        require(!isClaimRequired(_claim), "claim already in the list of required claims");
        requiredClaims.push(_claim);
        emit ClaimRequired(_claim);
    }

    /**
     *  @dev See {IComplyDeFi-removeRequiredClaim}.
     */
    function removeRequiredClaim(uint _claim) external override onlyOwner {
        require(isClaimRequired(_claim), "claim already in the list of required claims");
        uint length = requiredClaims.length;
        for (uint i = 0; i < length; i++) {
            if (requiredClaims[i] == _claim) {
                requiredClaims[i] = requiredClaims[length - 1];
                requiredClaims.pop();
                emit ClaimUnRequired(_claim);
                break;
            }
        }

    }

    /**
     *  @dev See {IComplyDeFi-hasClaimTopic}.
     */
    function hasClaimTopic(address _issuer, uint _claimTopic) public view override returns (bool) {
        uint length = trustedIssuerClaims[_issuer].length;
        uint[] memory claimTopics = trustedIssuerClaims[_issuer];
        for (uint i = 0; i < length; i++) {
            if (claimTopics[i] == _claimTopic) {
                return true;
            }
        }
        return false;
    }

    /**
     *  @dev See {IComplyDeFi-isComply}.
     */
    function isComply(address _user) public view override returns (bool) {
        address _identity = (IIdFactory(factory)).getIdentity(_user);
        // check that the identity was deployed by the factory, other identities are not allowed
        require(_identity != address(0), 'invalid identity contract');
        // claim variables
        uint256 foundClaimTopic;
        uint256 scheme;
        address issuer;
        bytes memory sig;
        bytes memory data;
        uint256 claimTopic;
        // for loop on the claims required by the pattern
        for (claimTopic = 0; claimTopic < requiredClaims.length; claimTopic++) {
            // fetch claim IDs held by the identity
            bytes32[] memory claimIds = (IIdentity(_identity)).getClaimIdsByTopic(requiredClaims[claimTopic]);
            // if identity is not containing any claim, check is returning false
            if (claimIds.length == 0) {
                return false;
            }
            // for loop on the claims held by the identity to compare with the required claim currently checked
            for (uint256 j = 0; j < claimIds.length; j++) {
                (foundClaimTopic, scheme, issuer, sig, data, ) = (IIdentity(_identity)).getClaim(claimIds[j]);

                try IClaimIssuer(issuer).isClaimValid(IIdentity(_identity), requiredClaims[claimTopic], sig,
                    data) returns(bool _validity){
                    if (
                        _validity
                        && hasClaimTopic(issuer, requiredClaims[claimTopic])
                    ) {
                        j = claimIds.length;
                    }
                    if (!hasClaimTopic(issuer, requiredClaims[claimTopic]) && j == (claimIds.length - 1)) {
                        return false;
                    }
                    if (!_validity && j == (claimIds.length - 1)) {
                        return false;
                    }
                }
                catch {
                    if (j == (claimIds.length - 1)) {
                        return false;
                    }
                }
            }
        }
        return true;
    }


}
