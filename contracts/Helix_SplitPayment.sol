// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ERC20Permit.sol";

contract  Helix_SplitPayment {
   
    function SplitPayment(
        address[6] calldata tokenCreatorMsSellerUserHelix_addr,
        uint256[5] calldata creatorMsSellerHelixDeadline_value,
       uint8 v, bytes32 r, bytes32 s
    ) public returns (bool){
   
        ERC20Permit token =  ERC20Permit(tokenCreatorMsSellerUserHelix_addr[0]);
        uint256 totalValue = creatorMsSellerHelixDeadline_value[0] + creatorMsSellerHelixDeadline_value[1] + creatorMsSellerHelixDeadline_value[2] + creatorMsSellerHelixDeadline_value[3];
        require(
            token.balanceOf(tokenCreatorMsSellerUserHelix_addr[4]) >= totalValue,
            "Helix_SplitPayment::Insufficient funds"
        );
        
        token.permit(
            tokenCreatorMsSellerUserHelix_addr[4],
            address(this),
            totalValue,
            creatorMsSellerHelixDeadline_value[4],
            v,r,s 
        ); 

       
        require(
            token.allowance(
                tokenCreatorMsSellerUserHelix_addr[4],
                address(this)
            ) >= totalValue,
            "Helix_SplitPayment::Insufficient allowance"
        );

        
        //seller value
        token.transferFrom( 
            tokenCreatorMsSellerUserHelix_addr[4],
            tokenCreatorMsSellerUserHelix_addr[3],
            creatorMsSellerHelixDeadline_value[2]
        );

        //MS value
        token.transferFrom(
            tokenCreatorMsSellerUserHelix_addr[4],
            tokenCreatorMsSellerUserHelix_addr[2],
            creatorMsSellerHelixDeadline_value[1]
        );
        
        //creator value
        token.transferFrom(
            tokenCreatorMsSellerUserHelix_addr[4],
            tokenCreatorMsSellerUserHelix_addr[1],
            creatorMsSellerHelixDeadline_value[0]
        );

        //helix value
        token.transferFrom(
            tokenCreatorMsSellerUserHelix_addr[4],
            tokenCreatorMsSellerUserHelix_addr[5],
            creatorMsSellerHelixDeadline_value[3]
        );

        return true;
    }
}