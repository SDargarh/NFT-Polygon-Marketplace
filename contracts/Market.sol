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

    /* initiates the sale of an item
       Transfer the ownership of the item and funds between parties
    */
    function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant{
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;

        require(msg.value == price,"Submit the asking price to complete the purchase");
        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContrat).transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = payable(msg.sender);        
        idToMarketItem[itemId].sold = true;
        _itemSold.increment();
        owner.transfer(listingPrice);
    }

    //returns all unsold market items
    function fetchMarketItems() public view returns(MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = itemCount - _itemSold.current();
        uint currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for(uint i = 1; i <= itemCount; i++) {
            if(MarketItem[i].owner == address(0)){
                items[currentIndex] = MarketItem[i];
                currentIndex += 1;
            }
        }
        return items;
    }

    //returns only items that user has purchased
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0; //total items that user purchased
        uint currentIndex = 0;

        for(uint i = 1; i <= totalItemCount; i++) {
            if(MarketItem[i].owner == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint i = 1; i <= totalItemCount; i++) {
            if(MarketItem[i].owner == msg.sender){
                items[currentIndex] = MarketItem[i];
                currentIndex += 1;
            }
        }
        return items;
    }

    //returns only items that user has created
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0; //total items that user created
        uint currentIndex = 0;

        for(uint i = 1; i <= totalItemCount; i++) {
            if(MarketItem[i].seller == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint i = 1; i <= totalItemCount; i++) {
            if(MarketItem[i].seller == msg.sender){
                items[currentIndex] = MarketItem[i];
                currentIndex += 1;
            }
        }
        return items;
    }    
    
}