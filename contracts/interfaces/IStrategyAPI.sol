// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStrategyAPI {
    function harvestTrigger(uint256 callCost) external view returns (bool);
    function harvest() external;

    function tendTrigger(uint256 callCost) external view returns (bool);
    function tend() external;

    function strategist() external view returns (address);
    function vault() external view returns (address);
}