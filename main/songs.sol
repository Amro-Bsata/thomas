// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./OwnerNft.sol";
import "./FanNft.sol";
import "./CopyRightNft.sol";

contract Songs {

 struct song {
        uint32 song_id; 
        string song_name;
        string[] styles;
        string[] negativ_styels;
        string uri;
        uint32 fan_nft_maxSupply;
        uint32 copyright_nft_maxSupply;
        uint copyright_nft_price;
        address owner_nft_contract;
        address fan_nft_contract;
        address copyright_nft_contract;
        address owner;
    }

    uint32 public next_song_id = 0;
    bool private lock;
    mapping(uint32 => song) public songs;
    mapping(string => uint32[]) public genreToSongIds;

    

    constructor(){
    }


    event SongCreated(uint32 indexed songId, address indexed owner, string songName);
    
    modifier lock_function( ){
        require(!lock,"sorry someone else is creating a song now, please try again later");
        lock = true; // to avoid security bugs
        _;
        lock = false;
    }

    modifier only_owner(uint32 song_id){
        bool is_owner = msg.sender == songs[song_id].owner || msg.sender == songs[song_id].owner_nft_contract;
        require(is_owner,"you dont own this song");
        _;
    }



    function create_song(string memory song_name ,string[] calldata styles, string[] calldata negativ_styels , string calldata uri,
    uint32 fan_nft_maxSupply,uint32 copyright_nft_maxSupply,uint copyright_nft_price) public lock_function{
        
        OwnerNft owner_nft = new OwnerNft(song_name,msg.sender,next_song_id,address(this)); //Todo owner
        FanNft fan_nft =  new FanNft(song_name,fan_nft_maxSupply,next_song_id); // Erstellung eines neuen Contracts;
        CopyRightNft copyright_nft = new CopyRightNft(song_name,copyright_nft_maxSupply,copyright_nft_price, address(owner_nft),next_song_id);

        //song memory new_song = 
        songs[next_song_id] = song(next_song_id, song_name, styles, negativ_styels,uri, fan_nft_maxSupply,copyright_nft_maxSupply,
        copyright_nft_price,address(owner_nft),address(fan_nft),address(copyright_nft),address(msg.sender));

        add_song_to_genre_list(next_song_id,styles);

        next_song_id+=1;
        emit SongCreated(next_song_id -1 , address(msg.sender), song_name);

    }

    function get_song(uint32 song_id) public view returns (song memory) {
             return songs[song_id];
        }
    


    function add_song_to_genre_list(uint32 song_id, string[] calldata styles) private {

        for (uint i = 0; i < styles.length; i++){
        genreToSongIds[styles[i]].push(song_id);
            
        } 
    
    
    }

    function get_songs_by_genre(string calldata genre)  public view returns (uint32[] memory){

        return genreToSongIds[genre];
        }

    function update_owner(uint32 song_id, address new_owner) external  only_owner(song_id) {
        songs[song_id].owner = new_owner;

    }

}