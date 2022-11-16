// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ERC20Permit.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract HelixSubs is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable {
    
    struct  SubscriptionStruct {
       string  subscriptionID;
       string  productID ;
       uint subscriptionTimestamp;
       uint nextDueTimestamp;
       uint recurrence;
       address paymentToken;
       uint256 merchantValue;
       address merchantAddress;
       uint256 hellixValue;
       address helixAddress;
       uint256 creatorValue;
       uint256 approvedValue;
       uint256 deadline;
       address creatorAddress;
       address userAddrress;
       string userData;
       bool active;
       bool exists;
    }
    
    mapping (bytes32 => SubscriptionStruct)  Subscriptions;

    event SubscribeEvent(
         bytes32  subscriptionHash
    );

    event BillingEvent( 
        bytes32  subscriptionHash
    );

    event BillingError(
        bytes32  subscriptionHash,
        string reason
    );
    event UnsubscribeEvent(
        bytes32  subscriptionHash
    );

   
    function initialize() public initializer {
      
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}


//PUBLIC FUNCTIONS -----------------------------------------------------------------------------------

    function Subscribe (
        string memory productID,
        string calldata subscriptionID,
        address[5] calldata tokenMerchantHelixCreatorUser_addr,
        uint256[6] calldata merchantHelixCreatorApprovedDeadlineTime_value,
        uint recurrence,
        string calldata userData, 
        uint8[2] memory v, bytes32[2] memory r, bytes32[2] memory s
    ) public returns(bool sucess) {
        require(msg.sender == owner(), "Helix:: Only owner can call subscribe function");
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                productID,
                subscriptionID,
                tokenMerchantHelixCreatorUser_addr,
                merchantHelixCreatorApprovedDeadlineTime_value,
                recurrence,
                userData
            )
        );

        msgHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                msgHash
            )
        );
        require(isSignedBy(owner(),msgHash,v[0],r[0],s[0]), "Helix::Invalid Signature");  
       
        SubscriptionStruct memory subscription = Subscriptions[msgHash];

        if(subscription.exists) {
            if(subscription.active){
                revert("Helix::Subscription already active");
            }
            else
            {
                if(callPermit(
                    subscription.paymentToken,
                    subscription.userAddrress,
                    subscription.approvedValue,
                    subscription.deadline,
                    v[1],
                    r[1],
                    s[1]
                ))
                {
                    if(TryBillSubscription(subscription))
                    {
                        subscription.active = true;
                        emit SubscribeEvent( msgHash);
                    }
                }
            }
        }
        else {             
                //add new subscription
                subscription.subscriptionID = subscriptionID;
                subscription.productID = productID;
                subscription.subscriptionTimestamp = block.timestamp;
                subscription.nextDueTimestamp = calculateNextDueTimestamp(block.timestamp,recurrence);
                subscription.recurrence = recurrence;
                subscription.paymentToken = tokenMerchantHelixCreatorUser_addr[0];
                subscription.merchantValue = merchantHelixCreatorApprovedDeadlineTime_value[0];
                subscription.merchantAddress = tokenMerchantHelixCreatorUser_addr[1];
                subscription.hellixValue = merchantHelixCreatorApprovedDeadlineTime_value[1];
                subscription.helixAddress = tokenMerchantHelixCreatorUser_addr[2];
                subscription.creatorValue = merchantHelixCreatorApprovedDeadlineTime_value[2];
                subscription.creatorAddress = tokenMerchantHelixCreatorUser_addr[3];
                subscription.userAddrress = tokenMerchantHelixCreatorUser_addr[4];
                subscription.approvedValue = merchantHelixCreatorApprovedDeadlineTime_value[3];
                subscription.deadline = merchantHelixCreatorApprovedDeadlineTime_value[4];
                subscription.userData = userData;
                subscription.active = true;
                subscription.exists = true;
                
                if(callPermit(
                    subscription.paymentToken,
                    subscription.userAddrress,
                    subscription.approvedValue,
                    subscription.deadline,
                    v[1],
                    r[1],
                    s[1]
                ))
                {
                    if(TryBillSubscription(subscription))
                    {
                        Subscriptions[msgHash] = subscription;
                        emit SubscribeEvent( msgHash);
                    }
                }
        }
 
       return true;
    }
    
    function Unsubscribre(bytes32 subsHash) public returns (bool){
        
        require(msg.sender == owner(), "Helix:: Only owner can call Unsubscribre function");

        SubscriptionStruct memory subscription = Subscriptions[subsHash];
        
        require(subscription.exists,"Helix::Subs not found");
        require(subscription.active,"Helix::Subs not active");
        require(subscription.userAddrress == subscription.userAddrress,"Helix::Only wallet that has subscribed can unsubscribe");

        Subscriptions[subsHash].active = false;
        
        emit UnsubscribeEvent(subsHash);

        return true;
    }

    function Billing(bytes32[] calldata subsHash) public returns (bool) {

        require(msg.sender == owner(),"Helix::Only owner can call billing function");

        for (uint i = 0; i < subsHash.length; i++) {

            SubscriptionStruct memory subscription = Subscriptions[subsHash[i]];

            require(subscription.exists,"Helix::Subs not found");
            require(subscription.active,"Helix::Subs not active");

            if(subscription.nextDueTimestamp <= block.timestamp) {

                try this.TryBillSubscription(subscription) returns (bool)
                {                
                    subscription.nextDueTimestamp = calculateNextDueTimestamp(
                        block.timestamp,
                        subscription.recurrence
                    );

                    emit BillingEvent(subsHash[i]);

                }catch(bytes memory reason)
                {
                    emit BillingError(subsHash[i],
                        string(reason)
                    );
                }
            }
        }
        return true;
    }

    function TryBillSubscription(SubscriptionStruct memory subscription) public returns(bool){

        ERC20Permit paymentToken = ERC20Permit(subscription.paymentToken);
        
        uint256 balance =  paymentToken.balanceOf(subscription.userAddrress);
        uint256 totalValue = subscription.merchantValue + subscription.hellixValue + subscription.creatorValue;
        require(balance >= totalValue, "Helix::Insufficient funds");
        
        uint256 allowance =  paymentToken.allowance(subscription.userAddrress, address(this));       
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


      function SubscriptionStructByHash( bytes32 subscriptionHash) external view returns(SubscriptionStruct memory subscription){
        subscription  = Subscriptions[subscriptionHash];
        require(subscription.exists,"Helix::Subs not found");
        return subscription;
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

    function callPermit(
        address paymentToken,
        address ownerAddress,
        uint256 approvedValue,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns (bool)
    {
          ERC20Permit token = ERC20Permit(paymentToken);

          token.permit(
            ownerAddress,
            address(this),
            approvedValue,
            deadline,
            v,r,s 
        ); 

        uint256 allowance =  token.allowance(ownerAddress, address(this));       
        require(allowance >= approvedValue, "Helix::Insufficient allowance");
        return true;
    }
  
}
