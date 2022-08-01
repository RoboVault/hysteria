// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

interface IKeeperRouter is Initializable, Ownable {

    function harvestTrigger(address strategyAddress, uint256 callCost) external view returns (bool);
    function harvest(address strategyAddress) external;

    function tendTrigger(address strategyAddress, uint256 callCost) external view returns (bool);
    function tend(address strategyAddress) external;

    function addPath(address resolverAddress, address keeperProxyAddress, address strategyAddress) external;
    function removePath(address resolverAddress, address strategyAddress) external;
    function clearPaths(address resolverAddress) external;

    function moveStrategy(address oldAddress, address newAddress) external;

    function setKeeperManager(address newKeeperManager) external;
}