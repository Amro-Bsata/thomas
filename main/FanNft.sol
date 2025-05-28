// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FanNft  is ERC721 {


        uint32 public  total_supply;
        uint32 token_id;
        uint32 public  max_supply;
        uint32 public available_supply;
        bool lock = false;
        uint32 public song_id;

        event tokenMinted(uint available_supply);


    constructor(string memory song_name, uint32 _max_supply,uint32 _song_id) ERC721(song_name,"FAN_NFT")  {
        max_supply = _max_supply;
        available_supply = _max_supply;
        song_id = _song_id;

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

    function mintToken()  external {
        mintToken(msg.sender);
        
    }

    function mintToken(address _to) public checkSupply(_to){
        super._safeMint(_to, token_id);
        token_id+=1;
        available_supply -= 1;
        total_supply += 1;
        emit tokenMinted(available_supply);
    }



}