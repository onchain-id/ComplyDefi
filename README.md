# ComplyDeFi 
## Introduction 
The goal of ComplyDeFi is to provide a simple contract to transform a permissionless DeFi protocol into a 
permissioned DeFi protocol. To do so, ComplyDeFi is leveraging the power of the ONCHAINID protocol, an open source & 
decentralized system providing identity smart contracts based on the implementation of ERC734 and ERC735. ComplyDeFi 
provides a very simple modifier that has to be added on the functions that require permissioning to ensure the 
caller of this function is eligible following the rules that the owner of the DeFi contract required. 

## How does it work? 
ComplyDeFi uses several functions to work properly, these functions are defined hereunder :

### ONCHAINID Factory
First of all, the primary need of ComplyDeFi is to know who is managing the wallets interacting with the protocol, 
or at least know that the user behind this wallet has an ONCHAINID and is eligible following the claim requirements. 
For that purpose, the ComplyDeFi contract needs to have access to the ONCHAINID address corresponding to any wallet 
trying to interact with it. The function used to do that is `getIdentity` that is available on the ONCHAINID Factory.
The link to the ONCHAINID Factory is therefore a critical point on any ComplyDeFi contract, that's why it is 
mandatory to give the address of the Factory contract in the constructor of any contract inheriting from ComplyDeFi. 
If the address was not set properly, it is still possible to fix it with the `setFactory` function available on the 
ComplyDeFi interface, this function can be called only by the contract owner obviously, as it is a critical function. 

### Claim Issuers 
The Claim Issuers are defined on the ONCHAINID protocol, basically Claim issuers are ONCHAINID contracts that are 
designed to emit claims for other ONCHAINIDs, they have the power to revoke a claim that they issued previously