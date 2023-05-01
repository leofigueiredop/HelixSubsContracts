// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ERC20Permit.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract  Helix_SplitPayment is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable {
   
    event PaymentEvent(
        string purchaseID
    );


    function initialize() public initializer {
      
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function SplitPayment(
        string calldata purchaseID,
        address[6] calldata tokenCreatorMsSellerUserHelix_addr,
        uint256[5] calldata creatorMsSellerHelixDeadline_value,
       uint8 v, bytes32 r, bytes32 s
    ) public onlyOwner returns (bool){
   
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
        if(creatorMsSellerHelixDeadline_value[2] > 0)
        {
            token.transferFrom( 
                tokenCreatorMsSellerUserHelix_addr[4],
                tokenCreatorMsSellerUserHelix_addr[3],
                creatorMsSellerHelixDeadline_value[2]
            );
        }

        //MS value
        if(creatorMsSellerHelixDeadline_value[1] > 0)
        {
            token.transferFrom(
                tokenCreatorMsSellerUserHelix_addr[4],
                tokenCreatorMsSellerUserHelix_addr[2],
                creatorMsSellerHelixDeadline_value[1]
            );
        }
        
        //creator value
        if(creatorMsSellerHelixDeadline_value[0] > 0)
        {
            token.transferFrom(
                tokenCreatorMsSellerUserHelix_addr[4],
                tokenCreatorMsSellerUserHelix_addr[1],
                creatorMsSellerHelixDeadline_value[0]
            );
        }

        //helix value
        if(creatorMsSellerHelixDeadline_value[3] > 0)
        {
            token.transferFrom(
                tokenCreatorMsSellerUserHelix_addr[4],
                tokenCreatorMsSellerUserHelix_addr[5],
                creatorMsSellerHelixDeadline_value[3]
            );
        }
         emit PaymentEvent(purchaseID);
        return true;
    }
}