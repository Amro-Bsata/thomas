// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



abstract contract  main {
    // function definition of the method we want to interact with
    function update_owner(uint32 song_id, address new_owner) external virtual;
}

contract OwnerNft is ERC721 {
    address public owner;
    uint8 public constant tokenID = 0;
    uint32 public song_id;
    main main_contract;
    


    event OwnerChanged(address indexed oldOwner, address newOwner);

    constructor(string memory song_name,address _owner,uint32 _song_id,address main_contract_address) ERC721(song_name,"OWNER_NFT") {
        owner = _owner;
        song_id = _song_id;
        super._mint(owner, tokenID);
        main_contract = main(main_contract_address);
    }
 

    
     modifier onlyOwner() {
        bool allowed = msg.sender == owner || super.getApproved(tokenID) == msg.sender;
        require(allowed,"Only the contract owner can do this");
         _; // executes the contract code in the function body
    }  
    
    function transferOwnership(address new_owner) public  onlyOwner{
        super._transfer(owner, new_owner, 0);
        emit OwnerChanged(owner,new_owner);
        owner = new_owner;
        main_contract.update_owner(song_id,new_owner);

    }

    
    function getOwner() public view returns(address){
        return owner;
    }

}
