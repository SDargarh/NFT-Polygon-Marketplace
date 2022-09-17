// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin\contracts\utils\Counters.sol";
import "@openzeppelin\contracts\token\ERC721\ERC721.sol";
import "@openzeppelin\contracts\security\ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold;

    address payable owner;
    uint256 listingPrice = 0.050 ether;

    constructor() {
        owner = payable(msg.sender);

    }
    

    struct MarketItem{
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping (uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //returns the listing price of the contract
    function getListingPrice() public view returns(uint256){
        return listingPrice;
    }

    //places an item for sale on the marketplace
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant{
        require(price > 0, "Price must be atleast 1Wei");
        require(msg.value == listingPrice, "payment must be equal to Listing Price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(itemId,
                                            nftContract,
                                            tokenID,
                                            payable(msg.sender),
                                            payable(address(0)),
                                            price,
                                            false);

        //ownership of the token is transfered from the nft creator to nft Marketplace
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenID);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenID,
            msg.sender,
            address(0),
            price,
            false
        );

    }




    
    
}