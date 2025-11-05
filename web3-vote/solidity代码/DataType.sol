// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract DataType {
    int x = -100;
    uint y = 10;

    uint8 z = 255;

    // int 的最大最小值
    int public minInt = type(int8).min;
    int public maxInt = type(int8).max;

    // uint 的最大最小值
    uint public minUInt = type(uint8).min;
    uint public maxUInt = type(uint8).max;

    constructor() payable {

    }

    address public a = msg.sender;
    address public b = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public c = address(this);
}

contract StringType {
    // string str = unicode'你好';

    string public str1 = "123";

    // 中文不适用unicode编码报错
    string public str2 = "123";

    // function concat() public view returns(string memory) {
    //     string memory result = string.concat(str1, str2);
    //     return result;
    // }

    function concat2(string memory _a, string memory _b) public view returns(string memory) {
        bytes memory _ba = bytes(str1);
        bytes memory _bb = bytes(str2);
        return string(bytes.concat(_ba, _bb));
    }

    function testString() public view returns(bool) {
        // bytes memory a = bytes(str1);
        // return a.length;
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function concat3() public view returns(string memory) {
        return string(abi.encodePacked(str1, str2));
    }
}