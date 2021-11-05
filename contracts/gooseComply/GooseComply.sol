pragma solidity ^0.8.0;

import "../gooseFinance/MasterChef.sol";
import "../ComplyDeFi.sol";

contract GooseComply is MasterChef, ComplyDeFi {

    constructor (
        address _factory,
        address _id,
        EggToken _egg,
        address _devaddr,
        address _feeAddress,
        uint256 _eggPerBlock,
        uint256 _startBlock)
    ComplyDeFi(_factory, _id)
    MasterChef(_egg, _devaddr, _feeAddress, _eggPerBlock, _startBlock) {

    }

    function deposit(uint256 _pid, uint256 _amount) public override onlyComply {
        super.deposit(_pid, _amount);
    }
}
