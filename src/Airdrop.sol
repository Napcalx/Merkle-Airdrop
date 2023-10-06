// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "solmate/src/utils/MerkleProofLib.sol";

contract Airdrop is ERC20{

    bytes32 public merkleRoot;
    //mapping of addresses who have claimed tokens
    mapping(address => bool) public claimed;

    constructor(bytes32 _root) ERC20("SkyToken", "SKY") {
        merkleRoot = _root;
    }

    //ERRORS
    error AddressHasClaimed();
    error InvalidProof();

    //Events
    event Claim(address account, uint256 amount);

    //Function to Claim
    function claim (
        address _claimer, 
        uint256 _amount, 
        bytes32 [] calldata _proof 
    )external returns (bool success){

        //Throws an Error if address has claimed
        if(claimed[_claimer]) revert AddressHasClaimed();
        
        //Verify Merkle Tree, and Throws an Error if claimer address not found
        bytes32 node = keccak256(abi.encodePacked(_claimer, _amount));
        success = MerkleProofLib.verify(_proof, merkleRoot, node);
        if(!success) revert InvalidProof();

        //Sets to state that the address has claimed
        claimed[_claimer] = true;

        // Mints token to address
        _mint(_claimer, _amount);

        //Emits claim Event
        emit Claim(_claimer, _amount);
    }
}
