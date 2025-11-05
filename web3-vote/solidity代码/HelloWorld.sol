// 智能合约的许可协议
// SPDX-License-Identifier: MIT;

pragma solidity ^0.8.7;

contract HelloWorld {
    // 状态变量
    string public name;

    constructor() payable {
        name = 'web3';
    }

    function sayName() public view returns(string memory) {
        return name;
    }

    function changeName (string memory _name) public {
        // x 局部变量
        // uint x = 100;
        // name 状态变量
        name = _name;
        assert(3 > 5);
        // msg 全局变量
        // address a = msg.sender;
    }
}