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
    event BillingEvent( bytes32 indexed subscriptionHash, SubscriptionStruct subscriptionObject);
    event UnsubscribeEvent( bytes32 indexed subscriptionHash, SubscriptionStruct subscriptionObject);

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
                if(tryBillSubscription(msgHash,subscription))
                {
                    subscription.active = true;
                    emit SubscribeEvent( msgHash, subscription);
                }
            }
        }
        else {
             
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

                if(tryBillSubscription(msgHash,subscription))
                {
                    Subscriptions[msgHash] = subscription;
                    emit SubscribeEvent( msgHash, subscription);
                }
        }
 
       return true;
    }
    
    function Unsubscribre(bytes32 subsHash) public returns (bool){
        SubscriptionStruct memory subscription = Subscriptions[subsHash];

        require(subscription.exists,"Helix::Subs not found");
        require(subscription.active,"Helix::Subs not active");
        require(subscription.userAddrress == msg.sender,"Helix::Only wallet that has subscribed can unsubscribe");

        Subscriptions[subsHash].active = false;
        
        emit UnsubscribeEvent( subsHash, subscription);

        return true;
    }

    function Billing(bytes32[] memory subsHash) public 
    {
        require(msg.sender == owner,"Helix::Only owner can call billing function");
        for (uint i = 0; i < subsHash.length; i++) {

            SubscriptionStruct memory subscription = Subscriptions[subsHash[i]];
            
            require(subscription.exists,"Helix::Subs not found");
            require(subscription.active,"Helix::Subs not active");
         
            tryBillSubscription(subsHash[i],subscription);
        
        }
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

    function tryBillSubscription(bytes32 msgHash, SubscriptionStruct memory subscription) private returns(bool sucess)
    {
        address[4] memory tokenMerchantHelixCreator_addr = [subscription.paymentToken, subscription.merchantAddress, subscription.helixAddress, subscription.creatorAddress];
        uint256[3] memory merchantHelixCreator_value = [subscription.merchantValue, subscription.hellixValue, subscription.creatorValue];
        
        uint256 allowance =  ERC20(tokenMerchantHelixCreator_addr[0]).allowance(msg.sender, address(this));
        uint256 balance =  ERC20(tokenMerchantHelixCreator_addr[0]).balanceOf(msg.sender);
        
        require(balance >= merchantHelixCreator_value[0] + merchantHelixCreator_value[1] + merchantHelixCreator_value[2], "Helix::Insufficient funds");
        require(allowance >= merchantHelixCreator_value[0] + merchantHelixCreator_value[1] + merchantHelixCreator_value[2], "Helix::Insufficient allowance");

        ERC20(tokenMerchantHelixCreator_addr[0]).transferFrom(msg.sender,tokenMerchantHelixCreator_addr[1],merchantHelixCreator_value[0]);//merchant value
        ERC20(tokenMerchantHelixCreator_addr[0]).transferFrom(msg.sender,tokenMerchantHelixCreator_addr[2],merchantHelixCreator_value[1]);//helix value
        ERC20(tokenMerchantHelixCreator_addr[0]).transferFrom(msg.sender,tokenMerchantHelixCreator_addr[3],merchantHelixCreator_value[2]);//creator value
        
        
        emit BillingEvent( msgHash, subscription);

        return true;
    }

  
}
