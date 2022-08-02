// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKeeperRegistry {
  function FAST_GAS_FEED (  ) external view returns ( address );
  function LINK (  ) external view returns ( address );
  function getCanceledUpkeepList (  ) external view returns ( uint256[] calldata );
  function getConfig (  ) external view returns ( uint32 paymentPremiumPPB, uint24 blockCountPerTurn, uint32 checkGasLimit, uint24 stalenessSeconds, uint16 gasCeilingMultiplier, uint256 fallbackGasPrice, uint256 fallbackLinkPrice );
  function getFlatFee (  ) external view returns ( uint32 );
  function getKeeperInfo ( address query ) external view returns ( address payee, bool active, uint96 balance );
  function getKeeperList (  ) external view returns ( address[] calldata );
  function getMaxPaymentForGas ( uint256 gasLimit ) external view returns ( uint96 maxPayment );
  function getMinBalanceForUpkeep ( uint256 id ) external view returns ( uint96 minBalance );
  function getRegistrar (  ) external view returns ( address );
  function getUpkeep ( uint256 id ) external view returns ( address target, uint32 executeGas, bytes calldata checkData, uint96 balance, address lastKeeper, address admin, uint64 maxValidBlocknumber );
  function getUpkeepCount (  ) external view returns ( uint256 );
  function owner (  ) external view returns ( address );
  function paused (  ) external view returns ( bool );
  function typeAndVersion (  ) external view returns ( string calldata );
}  