pragma solidity ^0.8.0;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract MultiKeeper is Ownable {
    using Address for address;
    using SafeMath for uint256;

    mapping(address => ResolverInfo) public resolverInfo;
    mapping(address => mapping(address =>))

    struct ResolverInfo {
        address[] keepers;
        uint256 currentIndex;
        bool isActive;
    }

    function getResolverInfo(address resolverAddress) internal returns (ResolverInfo) {
        require(resolverInfo[resolverAddress].isActive, "!resolverAddress");
        return resolverInfo[resolverAddress];
    }

    function resetIndex() external {
        getResolverInfo(msg.sender).currentIndex = 0;
    }

    function getCurrent() external returns (address) {
        ResolverInfo info = getResolverInfo(msg.sender);
        return info.keepers[info.currentIndex];
    }
    
    function next() external {
        ResolverInfo info = getResolverInfo(msg.sender);
        info.currentIndex++;
        if(info.currentIndex >= info.keepers.length) {
            info.currentIndex = 0;
        }
    }

    function addResolver(address resolverAddress) public onlyOwner {
        if(resolverInfo[resolverAddress].isActive) {
            revert("Resolver already active");
        }
        resolverInfo[resolverAddress].isActive = true;
    }

    function addKeeperToResolver(address keeper, address resolver) public onlyOwner {
        ResolverInfo info = getResolverInfo(resolver);

        // The keeper contract must have the resolver as a valid keeper (must have the GenericKeeper role)

    }


    


    
}
