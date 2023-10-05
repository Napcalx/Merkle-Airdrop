// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SkyToken is ERC20, Ownable {
    constructor() ERC20("SkyToken", "SKY") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}