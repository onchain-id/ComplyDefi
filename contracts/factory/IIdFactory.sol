pragma solidity ^0.8.0;

interface IIdFactory {
    function createIdentity(address _wallet, string memory _salt) external returns (address);

    function linkWallet(address _newWallet) external;

    function unlinkWallet(address _oldWallet) external;

    function getIdentity(address _wallet) external view returns (address);
}
