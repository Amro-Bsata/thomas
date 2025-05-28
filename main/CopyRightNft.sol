// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./OwnerNft.sol";

contract CopyRightNft is ERC721 {


        uint32 public  total_supply;
        uint32 token_id = 0;
        uint32 public  max_supply;
        uint32 public available_supply;
        uint public price;
        bool lock = false;
        address owner_contract_address;
        uint32 public song_id;

        event tokenMinted(uint available_supply);

    constructor(string memory song_name, uint32 _max_supply,uint _price,address _owner_contract_address,uint32 _song_id) ERC721(song_name,"COPYRIGHT_NFT")  {
        max_supply = _max_supply;
        available_supply = _max_supply;
        price = _price;
        owner_contract_address = _owner_contract_address;
        song_id = _song_id;
    }


    function setPrice(uint _price) public onlyOwner  {
            price = _price;
        }

     modifier onlyOwner() {
        address owner = OwnerNft(owner_contract_address).getOwner();
        bool allowed = msg.sender == owner || super.getApproved(token_id) == msg.sender;
        require(allowed,"Only the contract owner can do this");
         _; // executes the contract code in the function body
    } 

     modifier checkSupply(address user){
        require(!lock,"sorry someone else is minting now, please try again later");
        lock = true; // to avoid security bugs
        require (available_supply > 0, "sorry not enough supply");
        bool has_minted = super.balanceOf(user) > 0 ? true : false ;
        require(has_minted == false , "you have already minted");
        _;
        lock = false;
    }

    modifier checkGivenAmount(uint given_amount){
        if(given_amount < price)
        {
            revert("the given amount is not enough");
        }

        if (given_amount > price){
            uint to_return_amount = given_amount - price;
            payable(msg.sender).transfer(to_return_amount);
        }
        _;
    }



    function mintToken()  external payable{
        mintToken(msg.sender);
        
    }

    function mintToken(address _to) public payable  checkSupply(_to) checkGivenAmount(msg.value){
        super._safeMint(_to, token_id);
        token_id+=1;
        available_supply -= 1;
        total_supply += 1;
        emit tokenMinted(available_supply);
        
        address owner = OwnerNft(owner_contract_address).getOwner();
        payable(owner).transfer(price);

    }



}