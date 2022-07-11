// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

/**
 * This interface is here for the keeper proxy to interact
 * with the strategy
 */
interface CoreStrategyAPI {
    function harvestTrigger(uint256 callCost) external view returns (bool);
    function harvest() external;
    function calcDebtRatio() external view returns (uint256);
    function debtLower() external view returns (uint256);
    function debtUpper() external view returns (uint256);
    function calcCollateral() external view returns (uint256);
    function collatLower() external view returns (uint256);
    function collatUpper() external view returns (uint256);
    function rebalanceDebt() external;
    function rebalanceCollateral() external;
    function strategist() external view returns (address);
    function vault() external view returns (address);
}

interface IVault {
    function strategies(address _strategy) external view returns(uint256 performanceFee, uint256 activation, uint256 debtRatio, uint256 minDebtPerHarvest, uint256 maxDebtPerHarvest, uint256 lastReport, uint256 totalDebt, uint256 totalGain, uint256 totalLoss);
}

abstract contract KeeperProxy {
    // TODO roles for harvest and rebalance/tend, and Generic (used only to add resolvers to the MultiKeeper)
    // TODO methods of KeeperProxyHysteria, but more generic
    // TODO
}
