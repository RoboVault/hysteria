// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IStrategyAPI.sol";
import "./BaseKeeperProxy.sol";

/**
 * This interface is here for the keeper proxy to interact
 * with the strategy
 */
interface IJoint {
    function calcDebtRatio() external view returns (uint256, uint256);
    function debtUpper() external view returns (uint256);
    function rebalanceDebt() external;
    function tokens(uint256 i) external view returns (address);
    function strategies(address token) external view returns (address);
}

/**
 * @title Robovault Keeper Proxy
 * @author robovault
 * @notice
 *  KeeperProxy implements a proxy for Robovaults JointLP Strategy. The proxy provide
 *  More flexibility will roles, allowing for multiple addresses to be granted
 *  keeper permissions.
 *
 */
contract KeeperProxyJointLP is BaseKeeperProxy {
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
        return debtTriggerHysteria();
    }

    function tend() external override {
        _onlyKeepers();
        IJoint(strategy).rebalanceDebt();
    }

    function isInactive() public override view returns (bool) {
        return false; // Not working?
        // ( , , uint256 debtRatio0, , , , , ,) = IVault(vault0()).strategies(providerStrategy0());
        // ( , , uint256 debtRatio1, , , , , ,) = IVault(vault1()).strategies(providerStrategy0());
        // return debtRatio0 == 0 || debtRatio1 == 0;
    }

    /**
     * @notice
     * Returns true if a debt rebalance is required. 
     */
    function debtTriggerHysteria() public view returns (bool _canExec) {    
        if (!isInactive()) {    
            (uint256 debtRatio0, uint256 debtRatio1) = IJoint(strategy).calcDebtRatio();
            _canExec = (debtRatio0 > (IJoint(strategy).debtUpper().add(hysteriaDebt)) || debtRatio1 > (IJoint(strategy).debtUpper().add(hysteriaDebt)));           
        }
    }

    /*
     * JointLP Helpers
     */
    function token0() public view returns (address) {
        return IJoint(strategy).tokens(0);
    }

    function token1() public view returns (address) {
        return IJoint(strategy).tokens(1);
    }

    function providerStrategy0() public view returns (address) {
        return IJoint(strategy).strategies(token0());
    }

    function providerStrategy1() public view returns (address) {
        return IJoint(strategy).strategies(token1());
    }


    function vault0() public view returns (address) {
        return IStrategyAPI(providerStrategy0()).vault();
    }

    function vault1() public view returns (address) {
        return IStrategyAPI(providerStrategy1()).vault();
    }

    /**
     * @notice
     * Returns true if a debt rebalance is required. This adds an offset of "hysteriaDebt" to the
     * debt trigger thresholds to filter noise. Google Hysterisis
     */
    function debtTrigger() public view returns (bool _canExec) {
        if (!isInactive()) {    
            (uint256 debtRatio0, uint256 debtRatio1) = IJoint(strategy).calcDebtRatio();
            _canExec = (debtRatio0 > (IJoint(strategy).debtUpper()) || debtRatio1 > (IJoint(strategy).debtUpper()));           
        }
    }
    
    function updateHysteria(uint256 _hysteriaDebt,uint256 _hysteriaCollateral) external {
        _onlyStrategist();
        hysteriaDebt = _hysteriaDebt;
        hysteriaCollateral = _hysteriaCollateral;        
    }

    function calcDebtRatio() external view returns (uint256, uint256) {
        return IJoint(strategy).calcDebtRatio();
    }

    function rebalanceDebt() external {
        _onlyKeepers();
        IJoint(strategy).rebalanceDebt();
    }
}
