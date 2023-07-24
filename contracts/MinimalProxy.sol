// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MinimalProxy
 * @notice A minimal proxy contract that forwards all calls to a specified logic contract.
 */
contract MinimalProxy {
    address public logicContract;

    /**
     * @notice Initializes the minimal proxy contract with the address of the logic contract.
     * @param _logicContract The address of the logic contract to which all calls will be forwarded.
     */
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    /**
     * @notice Fallback function to forward calls to the logic contract.
     * @dev It delegates all calls to the logic contract using the DELEGATECALL opcode.
     * @dev Any returned data or revert message from the logic contract is passed back to the caller.
     */
    fallback() external payable {
        address target = logicContract;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), target, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    /**
     * @notice Receive function to receive Ether when sending transactions to the contract without data.
     * @dev This function allows the contract to receive Ether without any specific function call.
     */
    receive() external payable {}
}
