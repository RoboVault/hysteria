// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelinupgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";

import "./interfaces/IVault.sol";
import "./interfaces/IStrategyAPI.sol";


/**
 * @title Robovault Base Keeper Proxy
 * @author robovault
 * @notice
 *  KeeperProxy implements a base proxy keeper for Robovaults Strategies. The proxy provide
 *  More flexibility with roles and triggers.
 *
 */
abstract contract BaseKeeperProxy is Initializable, ReentrancyGuardUpgradeable {
    using Address for address;
    using SafeMath for uint256;

    address public strategy;
    mapping(address => bool) public keepers;
    address[] public keepersList;


    error BaseKeeperProxy_IdxNotFound();

    function _initialize(address _strategy) internal {
        setStrategyInternal(_strategy);
        __ReentrancyGuard_init();
    }

    function _onlyStrategist() internal {
        require(msg.sender == IStrategyAPI(strategy).strategist());
    }

    /**
     * @notice
     *  Only the strategist and approved keepers can call authorized
     *  functions
     */
    function _onlyKeepers() internal {
        require(
            keepers[msg.sender] == true || msg.sender == IStrategyAPI(strategy).strategist(),
            "!authorized"
        );
    }

    /**
     * @notice
     * Returns true if the debt ratio of the strategy is 0. debt ratio in this context is
     * the debt allocation of the vault, not the strategies debt ratio. 
     */
    function isInactive() public virtual view returns (bool) {
        address vault = IStrategyAPI(strategy).vault();
        ( , , uint256 debtRatio, , , , , ,) = IVault(vault).strategies(address(strategy));
        return (debtRatio == 0);
    }

    function setStrategy(address _strategy) external {
        _onlyStrategist();
        setStrategyInternal(_strategy);
    }

    function addKeeper(address _newKeeper) external {
        _onlyStrategist();
        keepers[_newKeeper] = true;
        keepersList.push(_newKeeper);
    }

    function removeKeeper(address _removeKeeper) external {
        _onlyStrategist();
        uint256 idx = findKeeperIdx(_removeKeeper);
        keepers[_removeKeeper] = false;
        keepersList[idx] = keepersList[keepersList.length - 1];
        keepersList.pop();
    }

    function findKeeperIdx(address _keeper) public view returns (uint256) {
        for (uint i = 0; i < keepersList.length; i++) {
            if (keepersList[i] == _keeper) {
                return i;
            }
        }
        revert BaseKeeperProxy_IdxNotFound();
    }

    function harvestTrigger(uint256 _callCost) public virtual view returns (bool) {
        return IStrategyAPI(strategy).harvestTrigger(_callCost);
    }

    function harvest() public virtual nonReentrant {
        _onlyKeepers();
        IStrategyAPI(strategy).harvest();
    }

    function tendTrigger(uint256 _callCost) public virtual view returns (bool) {
        return IStrategyAPI(strategy).tendTrigger(_callCost);
    }

    function tend() external virtual nonReentrant {
        _onlyKeepers();
        IStrategyAPI(strategy).tend();
    }

    function setStrategyInternal(address _strategy) internal {
        strategy = _strategy;
    }
}
