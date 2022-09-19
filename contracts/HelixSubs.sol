// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HelixSubs {
    
    address public owner;

    struct  SubscriptionStruct {
       uint256 subscriptionConfigID;
       uint subscriptionTimestamp;
       uint nextDueTimestamp;
       uint recurrence;
       address paymentToken;
       uint256 merchantValue;
       address merchantAddress;
       uint256 hellixValue;
       address helixAddress;
       uint256 creatorValue;
       address creatorAddress;
       address userAddrress;
       string userData;
       bool active;
       bool exists;
    }
    
    mapping (bytes32 => SubscriptionStruct) Subscriptions;

    event SubscribeEvent( bytes32 indexed subscriptionHash, SubscriptionStruct subscriptionObject);

    constructor()  {
        owner = msg.sender;
    }



//PUBLIC FUNCTIONS -----------------------------------------------------------------------------------

    function Subscribe (uint256 subscriptionConfigID,
                        address[4] memory tokenMerchantHelixCreator_addr,
                        uint256[3] memory merchantHelixCreator_value,
                        uint recurrence,
                        string memory userData,//ID/Name/Email
                        uint8 v, bytes32 r, bytes32 s) public returns(bool sucess) {

        bytes32 msgHash = keccak256(abi.encodePacked(subscriptionConfigID,
                                                    tokenMerchantHelixCreator_addr,
                                                    merchantHelixCreator_value,
                                                    recurrence,
                                                    userData));

        msgHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(isSignedBy(owner,msgHash,v,r,s), "Helix::Invalid Signature");  
       
        SubscriptionStruct memory subscription = Subscriptions[msgHash];

        if(subscription.exists) {
            if(subscription.active){
                revert("Helix::Subscription already active");
            }
            else
            {
                if(tryBillSubscription(tokenMerchantHelixCreator_addr, merchantHelixCreator_value))
                {
                    subscription.active = true;
                    emit SubscribeEvent( msgHash, subscription);
                }
            }
        }
        else {
             if(tryBillSubscription(tokenMerchantHelixCreator_addr, merchantHelixCreator_value))
                {
                    //add new subscription
                    subscription.subscriptionConfigID = subscriptionConfigID;
                    subscription.subscriptionTimestamp = block.timestamp;
                    subscription.nextDueTimestamp = calculateNextDueTimestamp(block.timestamp,recurrence);
                    subscription.recurrence = recurrence;
                    subscription.paymentToken = tokenMerchantHelixCreator_addr[0];
                    subscription.merchantValue = merchantHelixCreator_value[0];
                    subscription.merchantAddress = tokenMerchantHelixCreator_addr[1];
                    subscription.hellixValue = merchantHelixCreator_value[1];
                    subscription.helixAddress = tokenMerchantHelixCreator_addr[2];
                    subscription.creatorValue = merchantHelixCreator_value[2];
                    subscription.creatorAddress = tokenMerchantHelixCreator_addr[3];
                    subscription.userAddrress = msg.sender;
                    subscription.userData = userData;
                    subscription.active = true;
                    subscription.exists = true;

                    Subscriptions[msgHash] = subscription;
                    emit SubscribeEvent( msgHash, subscription);
            }
        }
 
       return true;
    }



//PRIVATE FUNCTIONS----------------------------------------------

//function to verify authenticated signature
    function isSignedBy(address signer, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) private pure  returns (bool) {      
        if(ecrecover(msgHash, v, r, s) == signer)  
        {
            return true ;
        } 
        else
        {
            return false;
        }  
        
    }

    function calculateNextDueTimestamp(uint timestamp, uint recurrence) private pure returns(uint newDueTimestamp )
    {
       return timestamp + (recurrence * 24 * 60 *60);
    }

    function tryBillSubscription(address[4] memory tokenMerchantHelixCreator_addr, uint256[3] memory merchantHelixCreator_value) private returns(bool sucess)
    {
        uint256 allowance =  ERC20(tokenMerchantHelixCreator_addr[0]).allowance(msg.sender, address(this));
        uint256 balance =  ERC20(tokenMerchantHelixCreator_addr[0]).balanceOf(msg.sender);
        require(balance >= merchantHelixCreator_value[0] + merchantHelixCreator_value[1] + merchantHelixCreator_value[2], "Helix::Insufficient funds");
        require(allowance >= merchantHelixCreator_value[0] + merchantHelixCreator_value[1] + merchantHelixCreator_value[2], "Helix::Insufficient allowance");

        ERC20(tokenMerchantHelixCreator_addr[0]).transferFrom(msg.sender,tokenMerchantHelixCreator_addr[1],merchantHelixCreator_value[0]);//merchant value
        ERC20(tokenMerchantHelixCreator_addr[0]).transferFrom(msg.sender,tokenMerchantHelixCreator_addr[2],merchantHelixCreator_value[1]);//helix value
        ERC20(tokenMerchantHelixCreator_addr[0]).transferFrom(msg.sender,tokenMerchantHelixCreator_addr[3],merchantHelixCreator_value[2]);//creator value

        return true;
    }

  
}