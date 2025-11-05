// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract StoreType {
    string name;
}

contract Person {
   struct State {
       string name;
       string gender;
   }

   State public state;

   function setState(string calldata _name, string calldata _gender) external {
       state.name = _name;
       state.gender = _gender;
   }

   function getName() external view returns(string memory) {
       return state.name;
   }

    function changeGender(uint value) external {
        require(value == 0 || value == 1, 'Person: Input value error.');
        string memory newGender;
        newGender = value == 0 ? "female" : "male";
        state.gender = newGender;
    }

}

contract Counter {
    function start() external pure returns (uint sum) {
        uint a1 = 1;
        uint a2 = 1;
        uint a3 = 1;
        uint a4 = 1;
        uint a5 = 1;
        // uint a6 = 1;
        // uint a7 = 1;
        // uint a8 = 1;
        // uint a9 = 1;
        // uint a10 = 1;
        // uint a11 = 1;
        // uint a12 = 1;
        // uint a13 = 1;
        // uint a14 = 1;
        // uint a15 = 1;
        // sum = a1+a2+a3+a4+a5+a6+a7+a8+a9+a10+a11+a12+a13+a14+a15;
        sum = a1+a2+a3+a4+a5;
    }
}