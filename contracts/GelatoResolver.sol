// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelinupgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelinupgradeable/contracts/access/OwnableUpgradeable.sol";

interface IKeeperProxyBase {
    // Proxy Keeper Functions
    function tendTrigger(uint256 _callCost) external view returns (bool _canExec);
    function tend() external;
    function harvestTrigger(uint256 _callCost) external view returns (bool _canExec);
    function harvest() external;
}
interface IResolver {
    // Proxy Keeper Functions
    function tend() external;
    function harvest() external;
}

contract GelatoResolver is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;

    address public gelato; // Gelato address
    
    function initialize(address _owner, address _gelato) public initializer {
        _transferOwnership(_owner);
        gelato = _gelato;
    }

    modifier onlyGelato() {
        require(gelato == _msgSender() || owner() == _msgSender(), "GelatoResolver: !gelato");
        _;
    }

    function setGelato(address _gelato) external onlyOwner {
        gelato = _gelato;
    }

    function tendTrigger(address keeperProxy) public view returns (bool _canExec, bytes memory _execPayload) {
        _execPayload = abi.encodeWithSelector(IResolver.tend.selector, keeperProxy);
        _canExec = IKeeperProxyBase(keeperProxy).tendTrigger(1);
    }
    
    function tend(address keeperProxy) public onlyGelato {
        IKeeperProxyBase(keeperProxy).tend();
    }

    function harvestTrigger(address keeperProxy) public view returns (bool _canExec, bytes memory _execPayload) {
        _execPayload = abi.encodeWithSelector(IResolver.harvest.selector, keeperProxy);
        _canExec = IKeeperProxyBase(keeperProxy).harvestTrigger(1); // todo: use callcost
    }
    
    function harvest(address keeperProxy) public onlyGelato {
        // Only trigger if the harvest is needed
        require(IKeeperProxyBase(keeperProxy).harvestTrigger(1), "!HarvestTigger");
        IKeeperProxyBase(keeperProxy).harvest(); // todo: use callcost
    }
}

