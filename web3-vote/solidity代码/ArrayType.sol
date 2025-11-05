// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract ArrayType {
    uint[5] arr = [1, 4, 5, 6];

    function getArr() public view returns(uint[5] memory) {
        return arr;
    }

    function sumArray() public view returns(uint) {
        // arr.length = 0;
        uint sum = 0;
        for (uint i = 0; i < arr.length; i++) {
            sum += arr[i];
        }
        return sum;
    }

    function changeArray(uint _num) public {
        arr[1] = _num;
    }

    function pushArray(uint _num) public {
        // arr.push(_num);
        // arr.pop();
    } 
}

contract ArrayType2 {
    uint[] arr = [0];

    function getArr() public view returns(uint[] memory) {
        return arr;
    }

    function length() public view returns(uint) {
        return arr.length;
    }

    function push(uint ele) public {
        arr.push(ele);
    }
}

contract ArrayType3 {
    uint[2][2] arr = [[1, 2], [2, 3]];

    function setArr(uint x) public {
        arr[0][1] = x;
    }

    function showArr() public view returns(uint[2][2] memory) {
        return arr;
    }
}

contract ArrayType4 {
    uint[][] arr = [[1, 2], [2, 3]];

    function setArr(uint x) public {
        arr[0][1] = x;
    }

    function showArr() public view returns(uint[][] memory) {
        return arr;
    }

    function push(uint x) public {
        arr[0].push(x);
    }
}