// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract MappingType {
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint)) xxx;

    /* 
        {
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4: 1000000,
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2: 2000000,
        }

        {
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4: {
                0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db: 3000000
            },
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2: {
                0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db: 3000000
            }
        }
     */

    function setBalances(uint256 amount) public {
        balances[msg.sender] = amount;
    }

    function balanceOf() view public returns(uint256) {
        return balances[msg.sender];
    }
}