// SPDX-License-Identifier: Apache-2.0


// Copyright 2023 Stichting Block Foundation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


pragma solidity ^0.8.19;


// ============================================================================
// Contracts
// ============================================================================

/**
 * Housing cooperative Contract
 * @dev 
 */
contract HousingCooperative {

    // Struct
    // ========================================================================

    /**
     * House
     * @dev 
     */
    struct House {
        address id;
        string owner;
        uint price;
        bool forSale;
    }


    // Parameters
    // ========================================================================

    House[] public houses;


    // Mappings
    // ========================================================================

    // Map the house id to their index in the houses array
    mapping(address => uint) houseIndex;

    // Member balances
    mapping(address => uint) public balances;


    // Modifiers
    // ========================================================================

    // Only the owner of the house can perform certain operations
    modifier onlyHouseOwner(address _houseId) {
        require(
            msg.sender == houses[houseIndex[_houseId]].id,
            "You are not the owner of this house."
        );
        _;
    }

    // Events
    // ========================================================================

    event NewHouse(
        address id,
        string owner
    );

    event HouseSold(
        address id,
        string newOwner
    );


    // Methods
    // ========================================================================

    /**
     * addHouse
     * @dev 
     * @param _houseId The _houseId
     * @param _owner The _owner
     * @param _price The _price
     */
    function addHouse(
        address _houseId,
        string memory _owner,
        uint _price
    ) public {
        houses.push(House(_houseId, _owner, _price, false));
        houseIndex[_houseId] = houses.length - 1;
        emit NewHouse(_houseId, _owner);
    }

    /**
     * getHouse
     * @dev 
     * @param _houseId The _houseId
     */
    function getHouse(
        address _houseId
    ) public view returns (
        address,
        string memory,
        uint,
        bool
    ) {
        return (
            houses[houseIndex[_houseId]].id,
            houses[houseIndex[_houseId]].owner,
            houses[houseIndex[_houseId]].price,
            houses[houseIndex[_houseId]].forSale
        );
    }

    /**
     * changeOwner
     * @dev 
     * @param _houseId The _houseId
     */
    function changeOwner(
        address _houseId,
        string memory _newOwner
    ) public onlyHouseOwner(_houseId) {
        houses[houseIndex[_houseId]].owner = _newOwner;
    }

    /**
     * putForSale
     * @dev 
     * @param _houseId The _houseId
     */
    function putForSale(
        address _houseId
    ) public onlyHouseOwner(
        _houseId
    ) {
        houses[houseIndex[_houseId]].forSale = true;
    }

    /**
     * withdrawFunds
     * @dev 
     * @param amount The amount
     */
    function withdrawFunds(
        uint amount
    ) public {
        require(
            balances[msg.sender] >= amount,
            "Not enough funds."
        );
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    /**
     * buyHouse
     * @dev 
     * @param _houseId The _houseId
     */
    function buyHouse(
        address _houseId
    ) public payable {
        require(
            houses[houseIndex[_houseId]].forSale == true,
            "House not for sale."
        );
        require(
            msg.value >= houses[houseIndex[_houseId]].price,
            "Not enough Ether sent for the house."
        );
        balances[houses[houseIndex[_houseId]].id] += msg.value;
        houses[houseIndex[_houseId]].owner = msg.sender;
        houses[houseIndex[_houseId]].forSale = false;
        emit HouseSold(_houseId, msg.sender);
    }

}
