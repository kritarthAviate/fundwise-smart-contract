// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ILendingPoolAddressesProvider
 * @notice Interface for the Aave V2 LendingPoolAddressesProvider contract.
 */
interface ILendingPoolAddressesProvider {
    /**
     * @notice Returns the address of the Aave V2 LendingPool contract.
     * @return The address of the LendingPool contract.
     */
    function getLendingPool() external view returns (address);
}
