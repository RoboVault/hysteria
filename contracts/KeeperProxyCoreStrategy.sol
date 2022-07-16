// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelinupgradeable/contracts/proxy/utils/Initializable.sol";

import "./interfaces/IVault.sol";
import "./BaseKeeperProxy.sol";

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


/**
 * @title Robovault Keeper Proxy
 * @author robovault
 * @notice
 *  KeeperProxy implements a proxy for Robovaults CoreCoreStrategyAPI(strategy). The proxy provide
 *  More flexibility will roles, allowing for multiple addresses to be granted
 *  keeper permissions.
 *
 */
contract KeeperProxyCoreStrategy is BaseKeeperProxy {
    using Address for address;
    using SafeMath for uint256;

    uint256 public hysteriaDebt;
    uint256 public hysteriaCollateral;

    function initialize(address _strategy, uint256 _hysteriaDebt, uint256 _hysteriaCollateral) public initializer {
        hysteriaDebt = _hysteriaDebt;
        hysteriaCollateral = _hysteriaCollateral;
        _initialize(_strategy);
    }

    function tendTrigger(uint256 _callCost) public override view returns (bool) {
        return debtTriggerHysteria() || collatTriggerHysteria();
    }

    function tend() external override {
        _onlyKeepers();
        if (debtTrigger()) {
            CoreStrategyAPI(strategy).rebalanceDebt();
        } else {
            CoreStrategyAPI(strategy).rebalanceCollateral();
        }
    }

    /**
     * @notice
     * Returns true if a debt rebalance is required. 
     */
    function debtTrigger() public view returns (bool _canExec) {
        if (!isInactive()) {
            uint256 debtRatio = CoreStrategyAPI(strategy).calcDebtRatio();
            _canExec = debtRatio > CoreStrategyAPI(strategy).debtUpper() || debtRatio < CoreStrategyAPI(strategy).debtLower();           
        }
    }

    /**
     * @notice
     * Returns true if a debt rebalance is required. This adds an offset of "hysteriaDebt" to the
     * debt trigger thresholds to filter noise. Google Hysterisis
     */
    function debtTriggerHysteria() public view returns (bool _canExec) {
        if (!isInactive()) {
            uint256 debtRatio = CoreStrategyAPI(strategy).calcDebtRatio();
            _canExec = (debtRatio > (CoreStrategyAPI(strategy).debtUpper().add(hysteriaDebt)) || debtRatio < CoreStrategyAPI(strategy).debtLower().sub(hysteriaDebt));           
        }
    }
    
    /**
     * @notice
     * Returns true if a collateral rebalance is required. This adds an offset of "hysteriaCollateral" to the
     * collateral trigger thresholds to filter noise. 
     */
    function collatTrigger() public view returns (bool _canExec) {
        if (!isInactive()) {
            uint256 collatRatio = CoreStrategyAPI(strategy).calcCollateral();
            _canExec = collatRatio > CoreStrategyAPI(strategy).collatUpper() || collatRatio < CoreStrategyAPI(strategy).collatLower();
        }
    }
    
    /**
     * @notice
     * Returns true if a collateral rebalance is required. This adds an offset of "hysteriaCollateral" to the
     * collateral trigger thresholds to filter noise. 
     */
    function collatTriggerHysteria() public view returns (bool _canExec) {
        if (!isInactive()) {
            uint256 collatRatio = CoreStrategyAPI(strategy).calcCollateral();
            _canExec = (collatRatio > CoreStrategyAPI(strategy).collatUpper().add(hysteriaCollateral) || collatRatio < CoreStrategyAPI(strategy).collatLower().sub(hysteriaCollateral));
        }
    }

    function updateHysteria(uint256 _hysteriaDebt,uint256 _hysteriaCollateral) external {
        _onlyStrategist();
        hysteriaDebt = _hysteriaDebt;
        hysteriaCollateral = _hysteriaCollateral;        
    }

    function calcDebtRatio() external view returns (uint256) {
        return CoreStrategyAPI(strategy).calcDebtRatio();
    }

    function rebalanceDebt() external {
        _onlyKeepers();
        CoreStrategyAPI(strategy).rebalanceDebt();
    }

    function calcCollateral() external view returns (uint256) {
        return CoreStrategyAPI(strategy).calcCollateral();
    }

    function rebalanceCollateral() external {
        _onlyKeepers();
        CoreStrategyAPI(strategy).rebalanceCollateral();
    }
}
