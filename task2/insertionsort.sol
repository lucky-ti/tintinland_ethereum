// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

contract insertionsort{
    function sort(uint[] memory a) public pure returns(uint[] memory){
        require (a.length > 1 , "not need to sort");
        for(uint i = 1 ; i < a.length ; i++) {
            uint key = a[i];
            uint j = i;
            while ((j >= 1) && (key <= a[j-1])){
                a[j] = a[j-1];
                j--;
            }
            a[j] = key;
        }
        return a;
    }
}

