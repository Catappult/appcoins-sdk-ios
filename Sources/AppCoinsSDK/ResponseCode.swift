//
//  ResponseCode.swift
//  appcoins-sdk
//
//  Created by aptoide on 01/03/2023.
//

import Foundation

public enum ResponseCode: Int {
    /**
     * Success
     */
    case OK = 0
    /**
     * User pressed back or canceled a dialog
     */
    case USER_CANCELED = 1
    /**
     * The network connection is down
     */
    case SERVICE_UNAVAILABLE = 2
    /**
     * This billing API version is not supported for the type requested
     */
    case BILLING_UNAVAILABLE = 3
    /**
     * Requested SKU is not available for purchase
     */
    case ITEM_UNAVAILABLE = 4
    /**
     * Invalid arguments provided to the API
     */
    case DEVELOPER_ERROR = 5
    /**
     * Fatal error during the API action
     */
    case ERROR = 6
    /**
     * Failure to purchase since item is already owned
     */
    case ITEM_ALREADY_OWNED = 7
    /**
     * Failure to consume since item is not owned
     */
    case ITEM_NOT_OWNED = 8
}
