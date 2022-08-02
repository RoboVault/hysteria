// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKeeperManager {
    function addKeeperImplementation(address _implementation, uint256 _idx, string calldata _name) external;
    function modifyKeeperImplementation(uint256 _idx, address _newImplementationAddress, string calldata _name) external;
    function removeKeeperImplementation(uint256 _idx) external;
    function createProxy(address _strategy, string calldata _keeperImplementationName) external;
    function createProxy(address _strategy, uint256 _idx) external;


    
}