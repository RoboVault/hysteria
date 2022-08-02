// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IKeeperManager.sol";



contract KeeperManager is Ownable, IKeeperManager {
    using Address for address;
    using SafeMath for uint256;

    // Stores Keeper implementations
    struct ImplementationDetails { 
        uint256 idx;
        string name;
        address implementationAddress;
    }

    mapping(uint256 => ImplementationDetails) public implementationDetails;

    // Function to manage Keeper Implementations
    function isPresent(uint256 _idx) internal returns (bool) {
        return implementationDetails[_idx].implementationAddress != address(0x0);
    }

    function addKeeperImplementation(address _implementation, uint256 _idx, string calldata _name) public override onlyOwner {
        require(!isPresent(_idx));
        require(_implementation != address(0x0));
        implementationDetails[_idx].idx = _idx;
        implementationDetails[_idx].name = _name;
        implementationDetails[_idx].implementationAddress = _implementation;
    }
    
    function modifyKeeperImplementation(uint256 _idx, address _newImplementationAddress, string calldata _name) public override onlyOwner {
        require(isPresent(_idx));
        implementationDetails[_idx].idx = _idx;
        implementationDetails[_idx].name = _name;
        implementationDetails[_idx].implementationAddress = _newImplementationAddress;
    }

    function removeKeeperImplementation(uint256 _idx) public override onlyOwner {
        require(isPresent(_idx));
        delete implementationDetails[_idx];
    }


    function createProxy(address _strategy, string calldata _keeperImplementationName) public override onlyOwner  {
        //TODO Deploy a new Keeper Proxy
        //TODO add this new Keeper Proxy to router
    }

    function createProxy(address _strategy, uint256 _idx) public override onlyOwner {
        //TODO
    }



}
