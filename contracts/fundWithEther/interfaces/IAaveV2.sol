// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IAaveV2
 * @notice Interface for Aave V2 lending pool interactions to deposit and withdraw ETH.
 */
interface IAaveV2 {
    /**
     * @notice Deposits ETH into the Aave V2 lending pool.
     * @param lendingPool The address of the lending pool.
     * @param onBehalfOf The address of the user for whom the ETH is being deposited.
     * @param referralCode The referral code for the deposit.
     * @dev The sender must approve enough ETH to this contract before calling this function.
     */
    function depositETH(
        address lendingPool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    /**
     * @notice Withdraws a specified amount of ETH from the Aave V2 lending pool.
     * @param lendingPool The address of the lending pool.
     * @param amount The amount of ETH to be withdrawn.
     * @param to The address where the withdrawn ETH will be sent.
     * @dev The sender must have enough balance in the Aave V2 lending pool.
     */
    function withdrawETH(
        address lendingPool,
        uint256 amount,
        address to
    ) external;
}
