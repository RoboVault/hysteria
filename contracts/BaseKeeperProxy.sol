// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelinupgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/IVault.sol";
import "./interfaces/IStrategyAPI.sol";
import "./interfaces/IKeeperRouter.sol";


/**
 * @title Robovault Base Keeper Proxy
 * @author robovault
 * @notice
 *  BaseKeeperProxy implements a base proxy keeper for Robovaults Strategies. The proxy provide
 *  More flexibility with roles and triggers.
 *
 */
abstract contract BaseKeeperProxy is Initializable, ReentrancyGuardUpgradeable, AccessControl {
    using Address for address;
    using SafeMath for uint256;


    address public strategy;
    address public keeperRouter;

    bytes32 public constant HARVESTER_ROLE = keccak256("HARVESTER_ROLE");
    bytes32 public constant TENDER_ROLE = keccak256("TENDER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address[] public keepersList;

    function _initialize(address _strategy, address _keeperRouter) internal {
        setStrategyInternal(_strategy);
        keeperRouter = _keeperRouter;
        _grantRole(ADMIN_ROLE, keeperRouter);
        _setRoleAdmin(HARVESTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TENDER_ROLE, ADMIN_ROLE);
        __ReentrancyGuard_init();
    }

    /**
    * @notice The strategist can call methods that change some properties of the (extended) BaseKeeperProxy. 
    * For all the other functionaly (adding/removing keepers, change the strat etc) the strategist MUST go through the KeeperRouter
    */
    modifier onlyStrategist {
        require(msg.sender == IStrategyAPI(strategy).strategist());
        _;
    }

    modifier onlyRouter {
        require(msg.sender == keeperRouter);
        _;
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

    function setStrategy(address _strategy) external onlyRouter {
        setStrategyInternal(_strategy);
    }

    function addKeeper(address _newKeeper, bool canTend, bool canHarvest) external onlyRouter {
        if(canTend) {
            grantRole(TENDER_ROLE, _newKeeper);
        }
        if(canHarvest) {
            grantRole(HARVESTER_ROLE, _newKeeper);
        }
    }

    function removeTender(address _removeKeeper) external onlyRouter {
        revokeRole(TENDER_ROLE, _removeKeeper);
    }

    function removeHarvester(address _removeKeeper) external onlyRouter {
        revokeRole(HARVESTER_ROLE, _removeKeeper);
    }

    function harvestTrigger(uint256 _callCost) public virtual view returns (bool) {
        return IStrategyAPI(strategy).harvestTrigger(_callCost);
    }

    function harvest() public virtual nonReentrant onlyRouter {
        IStrategyAPI(strategy).harvest();
    }

    function tendTrigger(uint256 _callCost) public virtual view returns (bool) {
        return IStrategyAPI(strategy).tendTrigger(_callCost);
    }

    function tend() external virtual nonReentrant onlyRouter {
        IStrategyAPI(strategy).tend();
    }

    function setStrategyInternal(address _strategy) internal {
        strategy = _strategy;
    }
}
