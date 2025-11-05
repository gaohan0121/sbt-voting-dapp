// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract ErrorDemo {
    uint public x = 100;
    
    function doAssert() public returns(uint) {
        x = 200;
        require( 3 > 5, unicode"3 怎么能大于 5 呢？" );
        return x;
    }
}