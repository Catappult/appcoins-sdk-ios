//
//  Constants.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct Constants {
    
    static internal let purchaseBonus = NSLocalizedString("Purchase Bonus: %@ in APPC Credits", bundle: .module, comment: "")
    static internal let canSeeBonusText = NSLocalizedString("You can see this bonus in your next purchase.", bundle: .module, comment: "")
    static internal let earnedEnoughAppcText = NSLocalizedString("You earned enough AppCoins Credits for this purchase. Enjoy!", bundle: .module, comment: "")
    static internal let otherPaymentMethodsText = NSLocalizedString("Other payment methods", bundle: .module, comment: "")
    static internal let buyText = NSLocalizedString("Buy", bundle: .module, comment: "")
    static internal let cancelText = NSLocalizedString("Cancel", bundle: .module, comment: "")
    static internal let successText = NSLocalizedString("Success", bundle: .module, comment: "")
    static internal let bonusReceived = NSLocalizedString("%@ Bonus Received", bundle: .module, comment: "")
    static internal let tapToGoBack = NSLocalizedString("Tap to go back to the game", bundle: .module, comment: "")
    static internal let errorText = NSLocalizedString("Error", bundle: .module, comment: "")
    static internal let somethingWentWrong = NSLocalizedString("Oops, something went wrong. Try again!", bundle: .module, comment: "")
    static internal let somethingWentWrongShort = NSLocalizedString("Something went wrong!", bundle: .module, comment: "")
    static internal let appcSupport = NSLocalizedString("AppCoins Support", bundle: .module, comment: "")
    static internal let walletBalance = NSLocalizedString("Wallet Balance: ", bundle: .module, comment: "")
    static internal let noInternetTitle = NSLocalizedString("No internet connection", bundle: .module, comment: "")
    static internal let noInternetText = NSLocalizedString("It seems you're not connected to the Internet. Check your connection and try again!", bundle: .module, comment: "")
    static internal let retryConnection = NSLocalizedString("Retry Connection", bundle: .module, comment: "")
    static internal let supportAvailableSoonTitle = NSLocalizedString("Available Soon", bundle: .module, comment: "")
    static internal let supportAvailableSoonMessage = NSLocalizedString("AppCoins Support is not available at the moment", bundle: .module, comment: "")
    static internal let appcCredits = NSLocalizedString("AppCoins Credits", bundle: .module, comment: "")
    static internal let logOut = NSLocalizedString("Log out", bundle: .module, comment: "")
    static internal let chooseCard = NSLocalizedString("Choose a Card", bundle: .module, comment: "")
    static internal let addCard = NSLocalizedString("Add new card", bundle: .module, comment: "")
    static internal let titleWalletInitialSync = NSLocalizedString("You already have the AppCoins Wallet installed!", bundle: .module, comment: "")
    static internal let subtitleWalletInitialSync = NSLocalizedString("It seems your wallet is not synced yet!", bundle: .module, comment: "")
    static internal let bodyWalletInitialSync = NSLocalizedString("In just a few seconds you can sync the AppCoins Wallet to *earn even more rewards*.", bundle: .module, comment: "")
    static internal let syncWallet = NSLocalizedString("Sync Wallet", bundle: .module, comment: "")
    static internal let skipAndBuy = NSLocalizedString("Skip and buy", bundle: .module, comment: "")
    static internal let titleWalletInstallSuccess = NSLocalizedString("Install the AppCoins Wallet to receive *even more rewards*.", bundle: .module, comment: "")
    static internal let install = NSLocalizedString("Install", bundle: .module, comment: "")
    static internal let skip = NSLocalizedString("Skip", bundle: .module, comment: "")

}
