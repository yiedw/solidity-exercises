// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestErc20 is ERC20("Token", "token") {
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {}
}
