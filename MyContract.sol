// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Warranty {
    uint256 public trr = 0;

    address internal retailer_id;
    uint256 internal warrantyPeriod;
    address public owner_id;
    uint[] internal purchases;
    uint256 internal purchases_cnt;
    mapping(uint256 => bool) internal not_burnt;
    bool internal transfered = false;
    bool internal not_bought = true;

    struct tokkenSample {
        string productName;
        string serialNumber;
        uint256 warrantyPeriod;
        uint256 bought_on;
        bool not_pruchased;
    }

    constructor() {
        retailer_id = msg.sender;
        trr = 1;
    }

    modifier retailer(){
        require(msg.sender == retailer_id);
        _;
    }

    modifier owner(uint256 _id){
        require(msg.sender == owner_id && is_valid(_id) && not_burnt[_id]);
        _;
    }


    mapping(uint => tokkenSample) public details;
    mapping(uint => address) public owners;

    function addDetails(string memory _productName, string memory _serialNumber, uint256 _warrentyPeriod) public retailer {
        details[trr] = tokkenSample(_productName, _serialNumber,_warrentyPeriod,0, true);
        trr += 1;
    }


    function buy(uint id) public{
        if(details[id].not_pruchased){
            owners[id] = msg.sender;
            purchases.push(id);
            purchases_cnt += 1;
            details[id].not_pruchased = false;
            details[id].bought_on = block.timestamp;
            not_burnt[id] = true;
        }
    }

    function check_owner() internal returns(uint256){
        for(uint i=1; i<=purchases_cnt; i++){
            if(msg.sender==owners[purchases[i]]){
                return purchases[i];
            }
        }
        return 0;
    }

    function is_valid(uint256 _id) internal returns(bool){
        if(block.timestamp >= details[_id].bought_on+details[_id].warrantyPeriod){
            return false;
        }else{
            return true;
        }
    }

    function burn(uint256 _id) internal{
        not_burnt[_id] = false;
    }


    function transfer(address transfer_id, uint256 _id) public retailer{
        if(msg.sender==owners[_id]){
            owners[_id] = transfer_id;
        }
    }



    function extend_warrenty(uint256 t, uint256 _id) public retailer{
        details[_id].warrantyPeriod += t;
        details[_id].bought_on = block.timestamp;
    }

    function Remaining_Time(uint256 _id) public returns(uint256){
        if(details[_id].warrantyPeriod-block.timestamp > 0){
            return details[_id].warrantyPeriod-block.timestamp;
        }else{
            burn(_id);
            return 0;
        }
    }
    
}