// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTSwap {
    struct Order {
        address owner;
        uint256 price;
    }

    // NFT Order映射
    mapping(address => mapping(uint256 => Order)) public orders;

    // 上架
    function list(address nftContract, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must not be free");
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(
            nft.isApprovedForAll(msg.sender, address(this)),
            "Contract not approved"
        );

        orders[nftContract][tokenId] = Order({owner: msg.sender, price: price});
    }

    // 撤销订单
    function revoke(address nftContract, uint256 tokenId) external {
        Order storage order = orders[nftContract][tokenId];
        require(order.owner == msg.sender, "Not the order owner");

        delete orders[nftContract][tokenId];
    }

    // 更新订单价格
    function update(
        address nftContract,
        uint256 tokenId,
        uint256 newPrice
    ) external {
        require(newPrice > 0, "Price must not be free");
        Order storage order = orders[nftContract][tokenId];
        require(order.owner == msg.sender, "Not the order owner");

        order.price = newPrice;
    }

    // 购买
    function purchase(address nftContract, uint256 tokenId) external payable {
        Order storage order = orders[nftContract][tokenId];
        require(order.price > 0, "Order does not exist");
        require(msg.value >= order.price, "Insufficient payment");

        // 转移NFT给购买者
        IERC721(nftContract).safeTransferFrom(order.owner, msg.sender, tokenId);

        // 转账给卖家，退还多余的钱
        payable(order.owner).transfer(order.price);

        if (msg.value > order.price) {
            payable(msg.sender).transfer(msg.value - order.price);
        }

        delete orders[nftContract][tokenId];
    }
}
