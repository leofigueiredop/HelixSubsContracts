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
       uint256 approvedValue;
       uint256 deadline;
       address userAddrress;
       bool exists;
    }
    
    mapping (bytes32 => SubscriptionStruct)  Subscriptions;

    event SubscribeEvent(
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
        address[6] calldata tokenMerchantHelixCreatorUserSpender_addr,
        uint256[6] calldata merchantHelixCreatorApprovedDeadlineTime_value,
        uint recurrence,
        uint8  permitV, bytes32  permitR, bytes32 permitS
    ) public returns(bool sucess) {
        require(msg.sender == owner(), "Helix:: Only owner can call subscribe function");

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                productID,
                subscriptionID,
                tokenMerchantHelixCreatorUserSpender_addr,
                merchantHelixCreatorApprovedDeadlineTime_value,
                recurrence
            )
        );       
       
        SubscriptionStruct memory subscription = Subscriptions[msgHash];

        if(subscription.exists) {           
            revert("Helix:: Subscription already exists");
        }           
        else 
        {             
            //add new subscription
            subscription.subscriptionID = subscriptionID;
            subscription.productID = productID;
            subscription.subscriptionTimestamp = block.timestamp;
            subscription.nextDueTimestamp = calculateNextDueTimestamp(block.timestamp,recurrence);
            subscription.recurrence = recurrence;
            subscription.paymentToken = tokenMerchantHelixCreatorUserSpender_addr[0];
            subscription.userAddrress = tokenMerchantHelixCreatorUserSpender_addr[4];
            subscription.approvedValue = merchantHelixCreatorApprovedDeadlineTime_value[3];
            subscription.deadline = merchantHelixCreatorApprovedDeadlineTime_value[4];
            subscription.exists = true;

            if(
                callPermit(
                    subscription.paymentToken,
                    subscription.userAddrress,
                    tokenMerchantHelixCreatorUserSpender_addr[5],
                    subscription.approvedValue,
                    subscription.deadline,
                    permitV,
                    permitR,
                    permitS
                )
            )
            {
                if(
                    TryBillSubscription(
                        subscription,
                        merchantHelixCreatorApprovedDeadlineTime_value[0],
                        tokenMerchantHelixCreatorUserSpender_addr[1],
                        merchantHelixCreatorApprovedDeadlineTime_value[1],
                        tokenMerchantHelixCreatorUserSpender_addr[2],
                        merchantHelixCreatorApprovedDeadlineTime_value[2],
                        tokenMerchantHelixCreatorUserSpender_addr[3]
                    )
                )
                {
                    Subscriptions[msgHash] = subscription;
                    emit SubscribeEvent(msgHash);
                }
            }
        }
 
       return true;
    }
    
    function Billing(
        bytes32 subsHash,
        uint256 merchantValue,
        address merchantAddress,
        uint256 hellixValue,
        address helixAddress,
        uint256 creatorValue,
        address creatorAddress
    ) public returns (bool)
    {
        require(msg.sender == owner(),"Helix:: Only owner can call billing function");
      
        SubscriptionStruct memory subscription = Subscriptions[subsHash];

        require(subscription.exists, "Helix:: Subscription not found");
        
        require(subscription.nextDueTimestamp <= block.timestamp,"Helix:: Future due date") ;

        TryBillSubscription(
            subscription,
            merchantValue,
            merchantAddress,
            hellixValue,
            helixAddress,
            creatorValue,
            creatorAddress
        );               
        subscription.nextDueTimestamp = calculateNextDueTimestamp(
            block.timestamp,
            subscription.recurrence
        );

        return true;
    }

    function TryBillSubscription(
        SubscriptionStruct memory subscription,
        uint256 merchantValue,
        address merchantAddress,
        uint256 hellixValue,
        address helixAddress,
        uint256 creatorValue,
        address creatorAddress
    ) public returns(bool)
    {

        ERC20Permit paymentToken = ERC20Permit(subscription.paymentToken);
        
        uint256 balance =  paymentToken.balanceOf(subscription.userAddrress);
        uint256 totalValue = merchantValue + hellixValue + creatorValue;
        require(balance >= totalValue, "Helix:: Insufficient funds");
        
        uint256 allowance =  paymentToken.allowance(subscription.userAddrress, address(this));       
        require(allowance >= totalValue, "Helix:: Insufficient allowance");
        
        //merchant value
        if(merchantValue > 0)
        {
            paymentToken.transferFrom( 
                subscription.userAddrress,
                merchantAddress,
                merchantValue
            );
        }

        //helix value
        if(hellixValue > 0)
        {
            paymentToken.transferFrom(
                subscription.userAddrress,
                helixAddress,
                hellixValue
            );
        }
        
        //creator value
        if(creatorValue > 0)
        {
            paymentToken.transferFrom(
                subscription.userAddrress,
                creatorAddress,
                creatorValue
            );
        }
        return true;
    }


      function SubscriptionStructByHash( bytes32 subscriptionHash) external view returns(SubscriptionStruct memory subscription){
        subscription  = Subscriptions[subscriptionHash];
        require(subscription.exists,"Helix:: Subscription not found");
        return subscription;
      }

//PRIVATE FUNCTIONS---------------------------------------------- 
   

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
        address spender,
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
            spender,
            approvedValue,
            deadline,
            v,r,s 
        ); 

        uint256 allowance =  token.allowance(ownerAddress, address(this));       
        require(allowance >= approvedValue, "Helix:: Insufficient allowance");
        return true;
    }
  
}
