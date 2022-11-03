// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HelixSubs {
    
    address public owner;

    struct  SubscriptionStruct {
       string  productID;
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
    
    mapping  (bytes32 => SubscriptionStruct)  Subscriptions;

    event SubscribeEvent(
         bytes32  subscriptionHash,
         SubscriptionStruct subscriptionObject
    );

    event BillingEvent( 
        bytes32  subscriptionHash,
        SubscriptionStruct subscriptionObject
    );

    event BillingError(
        bytes32  subscriptionHash,
        SubscriptionStruct subscriptionObject,
        string reason
    );
    event UnsubscribeEvent(
        bytes32  subscriptionHash,
        SubscriptionStruct subscriptionObject
    );

    constructor()  {
        owner = msg.sender;
    }



//PUBLIC FUNCTIONS -----------------------------------------------------------------------------------

    function Subscribe (
        string calldata productID,
        address[5] calldata tokenMerchantHelixCreatorUser_addr,
        uint256[3] calldata merchantHelixCreator_value,
        uint recurrence,
        string calldata userData, //ID/Name/Email
        uint8 v, bytes32 r, bytes32 s
    ) public returns(bool sucess) {

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                productID,
                tokenMerchantHelixCreatorUser_addr,
                merchantHelixCreator_value,
                recurrence,
                userData
            )
        );

        msgHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32",
                msgHash
            )
        );
        require(isSignedBy(owner,msgHash,v,r,s), "Helix::Invalid Signature");  
       
        SubscriptionStruct memory subscription = Subscriptions[msgHash];

        if(subscription.exists) {
            if(subscription.active){
                revert("Helix::Subscription already active");
            }
            else
            {
                if(TryBillSubscription(subscription))
                {
                    subscription.active = true;
                    emit SubscribeEvent( msgHash, subscription);
                }
            }
        }
        else {             
                //add new subscription
                subscription.productID = productID;
                subscription.subscriptionTimestamp = block.timestamp;
                subscription.nextDueTimestamp = calculateNextDueTimestamp(block.timestamp,recurrence);
                subscription.recurrence = recurrence;
                subscription.paymentToken = tokenMerchantHelixCreatorUser_addr[0];
                subscription.merchantValue = merchantHelixCreator_value[0];
                subscription.merchantAddress = tokenMerchantHelixCreatorUser_addr[1];
                subscription.hellixValue = merchantHelixCreator_value[1];
                subscription.helixAddress = tokenMerchantHelixCreatorUser_addr[2];
                subscription.creatorValue = merchantHelixCreator_value[2];
                subscription.creatorAddress = tokenMerchantHelixCreatorUser_addr[3];
                subscription.userAddrress = tokenMerchantHelixCreatorUser_addr[4];
                subscription.userData = userData;
                subscription.active = true;
                subscription.exists = true;

                if(TryBillSubscription(subscription))
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
        require(subscription.userAddrress == subscription.userAddrress,"Helix::Only wallet that has subscribed can unsubscribe");

        Subscriptions[subsHash].active = false;
        
        emit UnsubscribeEvent(
            subsHash,
            subscription
        );

        return true;
    }

    function Billing(bytes32[] calldata subsHash) public returns (bool) {
        require(msg.sender == owner,"Helix::Only owner can call billing function");
        for (uint i = 0; i < subsHash.length; i++) {

            SubscriptionStruct memory subscription = Subscriptions[subsHash[i]];

            require(subscription.exists,"Helix::Subs not found");
            require(subscription.active,"Helix::Subs not active");

            if(subscription.nextDueTimestamp < block.timestamp) {

                try this.TryBillSubscription(subscription) returns (bool)
                {                
                    subscription.nextDueTimestamp = calculateNextDueTimestamp(
                        block.timestamp,
                        subscription.recurrence
                    );

                    emit BillingEvent(
                        subsHash[i],
                        subscription
                    );

                }catch(bytes memory reason)
                {
                    emit BillingError(
                        subsHash[i],
                        subscription,
                        string(reason)
                    );
                }
            }
        }
        return true;
    }

    function TryBillSubscription( SubscriptionStruct memory subscription) public returns(bool){
        
        ERC20 paymentToken = ERC20(subscription.paymentToken);
        uint256 allowance =  paymentToken.allowance(subscription.userAddrress, address(this));
        uint256 balance =  paymentToken.balanceOf(subscription.userAddrress);
        uint256 totalValue = subscription.merchantValue + subscription.hellixValue + subscription.creatorValue;
        
        require(balance >= totalValue, "Helix::Insufficient funds");
        require(allowance >= totalValue, "Helix::Insufficient allowance");
        
        //merchant value
        paymentToken.transferFrom( 
            subscription.userAddrress,
            subscription.merchantAddress,
            subscription.merchantValue
        );

        //helix value
        paymentToken.transferFrom(
            subscription.userAddrress,
            subscription.helixAddress,
            subscription.hellixValue
        );
        
        //creator value
        paymentToken.transferFrom(
            subscription.userAddrress,
            subscription.creatorAddress,
            subscription.creatorValue);
        
        
        return true;
    }

//PRIVATE FUNCTIONS----------------------------------------------

    //function to verify authenticated signature
    function isSignedBy(
        address signer,
        bytes32 msgHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private pure  returns (bool) {      
            
        if(ecrecover(msgHash, v, r, s) == signer)  
        {
            return true ;
        } 
        else
        {
            return false;
        }  
        
    }

    function calculateNextDueTimestamp(
        uint timestamp,
        uint recurrence
    ) private pure returns(uint newDueTimestamp )
    {
       return timestamp + (recurrence * 24 * 60 * 60);
    }
  
}
