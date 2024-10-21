//
//  Constants.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct Constants {
    
    // Purchase
    static internal let purchaseBonus = NSLocalizedString("purchase_bonus_title", bundle: .module, comment: "Purchase Bonus: %@ in AppCoins Credits")
    static internal let canSeeBonusText = NSLocalizedString("purchase_bonus_body", bundle: .module, comment: "You can use this bonus in your next purchase.")
    static internal let bonusNotAvailableText = NSLocalizedString("bonus_not_available", bundle: .module, comment: "Bonus not available with this payment method")
    static internal let earnedEnoughAppcText = NSLocalizedString("earned_enough_appc_body", bundle: .module, comment: "You earned enough AppCoins Credits for this purchase. Enjoy!")
    static internal let otherPaymentMethodsText = NSLocalizedString("other_payment_methods_body", bundle: .module, comment: "Other payment methods")
    static internal let buyText = NSLocalizedString("buy_button", bundle: .module, comment: "Buy")
    static internal let cancelText = NSLocalizedString("cancel_button", bundle: .module, comment: "Cancel")
    static internal let appcCredits = NSLocalizedString("appc_credits", bundle: .module, comment: "AppCoins Credits")
    static internal let logOut = NSLocalizedString("log_out_button", bundle: .module, comment: "Log out")
    static internal let chooseCard = NSLocalizedString("choose_card_title", bundle: .module, comment: "Choose a Card")
    static internal let addCard = NSLocalizedString("add_card_button", bundle: .module, comment: "Add new card")
    static internal let yourCard = NSLocalizedString("your_card_title", bundle: .module, comment: "Your card")
    
    // Success
    static internal let successText = NSLocalizedString("success_title", bundle: .module, comment: "Success")
    static internal let bonusReceived = NSLocalizedString("bonus_received_body", bundle: .module, comment: "%@ Bonus Received")
    static internal let walletBalance = NSLocalizedString("wallet_balance_body", bundle: .module, comment: "Wallet Balance: %@")
    static internal let tapToGoBack = NSLocalizedString("back_to_game_body", bundle: .module, comment: "Tap to go back to the game")
    
    // Error
    static internal let errorText = NSLocalizedString("error_title", bundle: .module, comment: "Error")
    static internal let somethingWentWrongShort = NSLocalizedString("something_went_wrong_title", bundle: .module, comment: "Something went wrong!")
    static internal let somethingWentWrong = NSLocalizedString("something_went_wrong_body", bundle: .module, comment: "Oops, something went wrong. Try again!")
    static internal let appcSupport = NSLocalizedString("appcoins_support_button", bundle: .module, comment: "AppCoins Support")
    static internal let noInternetTitle = NSLocalizedString("no_internet_title", bundle: .module, comment: "No internet connection")
    static internal let noInternetText = NSLocalizedString("no_internet_body", bundle: .module, comment: "It seems you're not connected to the Internet. Check your connection and try again!")
    static internal let retryConnection = NSLocalizedString("retry_connection_button", bundle: .module, comment: "Retry Connection")
    static internal let supportAvailableSoonTitle = NSLocalizedString("support_available_soon_title", bundle: .module, comment: "Available Soon")
    static internal let supportAvailableSoonMessage = NSLocalizedString("support_available_soon_body", bundle: .module, comment: "AppCoins Support is not available at the moment")
    
    // Sync
    static internal let titleWalletInitialSync = NSLocalizedString("wallet_already_installed_title", bundle: .module, comment: "You already have the AppCoins Wallet installed!")
    static internal let subtitleWalletInitialSync = NSLocalizedString("wallet_not_synced_title", bundle: .module, comment: "It seems your wallet is not synced yet!")
    static internal let bodyWalletInitialSync = NSLocalizedString("sync_wallet_body", bundle: .module, comment: "In just a few seconds you can sync the AppCoins Wallet to *earn even more rewards*.")
    static internal let syncWallet = NSLocalizedString("sync_wallet_button", bundle: .module, comment: "Sync Wallet")
    static internal let skipAndBuy = NSLocalizedString("skip_sync_button", bundle: .module, comment: "Skip and buy")
    static internal let titleWalletInstallSuccess = NSLocalizedString("install_wallet_body", bundle: .module, comment: "Install the AppCoins Wallet to receive *even more rewards*.")
    static internal let install = NSLocalizedString("install_button", bundle: .module, comment: "Install")
    static internal let skip = NSLocalizedString("skip_button", bundle: .module, comment: "Skip")
    
}
