//
//  Constants.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct Constants {
   
    // Purchase
    static internal let canSeeBonusText = NSLocalizedString("purchase_bonus_body", bundle: .APPCModule, comment: "You can use this bonus in your next purchase.")
    static internal let bonusNotAvailableText = NSLocalizedString("bonus_not_available", bundle: .APPCModule, comment: "Bonus not available with this payment method")
    static internal let earnedEnoughAppcText = NSLocalizedString("earned_enough_appc_body", bundle: .APPCModule, comment: "You earned enough AppCoins Credits for this purchase. Enjoy!")
    static internal let otherPaymentMethodsText = NSLocalizedString("other_payment_methods_body", bundle: .APPCModule, comment: "Other payment methods")
    static internal let buyText = NSLocalizedString("buy_button", bundle: .APPCModule, comment: "Buy")
    static internal let cancelText = NSLocalizedString("cancel_button", bundle: .APPCModule, comment: "Cancel")
    static internal let appcCredits = NSLocalizedString("appc_credits", bundle: .APPCModule, comment: "AppCoins Credits")
    static internal let logOut = NSLocalizedString("log_out_button", bundle: .APPCModule, comment: "Log out")
    static internal let chooseCard = NSLocalizedString("choose_card_title", bundle: .APPCModule, comment: "Choose a Card")
    static internal let addCard = NSLocalizedString("add_card_button", bundle: .APPCModule, comment: "Add new card")
    static internal let yourCard = NSLocalizedString("your_card_title", bundle: .APPCModule, comment: "Your card")
    static internal let selectPaymentMethodText = NSLocalizedString("select_payment_method_button", bundle: .APPCModule, comment: "Select payment method")
    static internal let signToGetBonusText = NSLocalizedString("sign_to_get_bonus_button", bundle: .APPCModule, comment: "Sign in to get your bonus")
    static internal let chooseYourPaymentMethod = NSLocalizedString("choose_your_payment_method_title", bundle: .APPCModule, comment: "Choose your payment method")

    // Success
    static internal let successText = NSLocalizedString("success_title", bundle: .APPCModule, comment: "Success")
    static internal let bonusReceived = NSLocalizedString("bonus_received_body", bundle: .APPCModule, comment: "%@ Bonus Received")
    static internal let walletBalance = NSLocalizedString("wallet_balance_body", bundle: .APPCModule, comment: "Wallet Balance: %@")
    static internal let tapToGoBack = NSLocalizedString("back_to_game_body", bundle: .APPCModule, comment: "Tap to go back to the game")

    // Error
    static internal let errorText = NSLocalizedString("error_title", bundle: .APPCModule, comment: "Error")
    static internal let somethingWentWrongShort = NSLocalizedString("something_went_wrong_title", bundle: .APPCModule, comment: "Something went wrong!")
    static internal let somethingWentWrong = NSLocalizedString("something_went_wrong_body", bundle: .APPCModule, comment: "Oops, something went wrong. Try again!")
    static internal let appcSupport = NSLocalizedString("appcoins_support_button", bundle: .APPCModule, comment: "AppCoins Support")
    static internal let noInternetTitle = NSLocalizedString("no_internet_title", bundle: .APPCModule, comment: "No internet connection")
    static internal let noInternetText = NSLocalizedString("no_internet_body", bundle: .APPCModule, comment: "It seems you're not connected to the Internet. Check your connection and try again!")
    static internal let retryConnection = NSLocalizedString("retry_connection_button", bundle: .APPCModule, comment: "Retry Connection")
    static internal let supportAvailableSoonTitle = NSLocalizedString("support_available_soon_title", bundle: .APPCModule, comment: "Available Soon")
    static internal let supportAvailableSoonMessage = NSLocalizedString("support_available_soon_body", bundle: .APPCModule, comment: "AppCoins Support is not available at the moment")

    // Sync
    static internal let titleWalletInitialSync = NSLocalizedString("wallet_already_installed_title", bundle: .APPCModule, comment: "You already have the AppCoins Wallet installed!")
    static internal let subtitleWalletInitialSync = NSLocalizedString("wallet_not_synced_title", bundle: .APPCModule, comment: "It seems your wallet is not synced yet!")
    static internal let bodyWalletInitialSync = NSLocalizedString("sync_wallet_body", bundle: .APPCModule, comment: "In just a few seconds you can sync the AppCoins Wallet to *earn even more rewards*.")
    static internal let syncWallet = NSLocalizedString("sync_wallet_button", bundle: .APPCModule, comment: "Sync Wallet")
    static internal let skipAndBuy = NSLocalizedString("skip_sync_button", bundle: .APPCModule, comment: "Skip and buy")
    static internal let titleWalletInstallSuccess = NSLocalizedString("install_wallet_body", bundle: .APPCModule, comment: "Install the AppCoins Wallet to receive *even more rewards*.")
    static internal let install = NSLocalizedString("install_button", bundle: .APPCModule, comment: "Install")
    static internal let skip = NSLocalizedString("skip_button", bundle: .APPCModule, comment: "Skip")

    // Login
    static internal let continueText = NSLocalizedString("continue_button", bundle: .APPCModule, comment: "Continue")
    static internal let signInWithGoogleText = NSLocalizedString("sign_in_with_google_button", bundle: .APPCModule, comment: "Sign in with Google")
    static internal let signInWithFacebookText = NSLocalizedString("sign_in_with_facebook_button", bundle: .APPCModule, comment: "Sign in with Facebook")
    static internal let emailLabel = NSLocalizedString("email_label", bundle: .APPCModule, comment: "Email")
    static internal let yourEmail = NSLocalizedString("your_email_here_placeholder", bundle: .APPCModule, comment: "Your email here")
    static internal let signInAndJoinTitle = NSLocalizedString("sign_in_and_join_us_title", bundle: .APPCModule, comment: "Sign in and join us!")
    static internal let getBonusEveryPurchase = NSLocalizedString("bonus_every_purchase_body", bundle: .APPCModule, comment: "You'll get a bonus on every purchase!")
    static internal let orContinueWith = NSLocalizedString("or_continue_with_body", bundle: .APPCModule, comment: "Or continue with:")
    static internal let invalidEmail = NSLocalizedString("invalid_email_body", bundle: .APPCModule, comment: "Invalid email address.")
    static internal let redeemBonusText = NSLocalizedString("redeem_bonus_button", bundle: .APPCModule, comment: "Redeem bonus")
    static internal let incorrectCode = NSLocalizedString("incorrect_code_body", bundle: .APPCModule, comment: "Your code is incorrect.")
    static internal let sentCodeTo = NSLocalizedString("sent_code_to_body", bundle: .APPCModule, comment: "We've sent a code to")
    static internal let codeLabel = NSLocalizedString("code_label", bundle: .APPCModule, comment: "Code")
    static internal let checkYourEmail = NSLocalizedString("check_your_email_body", bundle: .APPCModule, comment: "Check your email")

    // Non-final
    static internal let resendEmail = NSLocalizedString("resend_email_button", bundle: .APPCModule, comment: "Re-send Email")
    static internal let resendInTime = NSLocalizedString("resend_in_time_body", bundle: .APPCModule, comment: "If you have not received an email, you can retry again in %@ seconds.")
    static internal let loginFailed = NSLocalizedString("login_failed", bundle: .APPCModule, comment: "Login Failed")
    static internal let tryAgain = NSLocalizedString("try_again_button", bundle: .APPCModule, comment: "Try again")
    static internal let confirmLogOutText = NSLocalizedString("confirm_logout_body", bundle: .APPCModule, comment: "Are you sure you want to log out?")
    static internal let purchaseBonus = NSLocalizedString("purchase_bonus_title", bundle: .APPCModule, comment: "*Purchase Bonus:* %@ in AppCoins Credits")
    static internal let signInButton = NSLocalizedString("sign_in_button", bundle: .APPCModule, comment: "Sign in")
    static internal let signInToRedeem = NSLocalizedString("sign_in_to_redeem_body", bundle: .APPCModule, comment: "You've earned %@ from your in-app purchases. Sign in to receive it and use it in your next purchases!")
    static internal let yourBalance = NSLocalizedString("your_balance_body", bundle: .APPCModule, comment: "Your Balance: %@")
    static internal let consentEmailBody = NSLocalizedString("consent_email_body", bundle: .APPCModule, comment: "I authorize Aptoide to use my email for marketing purposes")
    static internal let acceptTermsBody = NSLocalizedString("accept_terms_body", bundle: .APPCModule, comment: "I accept Aptoide's %@ and %@")
    static internal let termsAndConditions = NSLocalizedString("terms_conditions_body", bundle: .APPCModule, comment: "Terms and Conditions")
    static internal let privacyPolicy = NSLocalizedString("privacy_policy_body", bundle: .APPCModule, comment: "Privacy Policy")
    
}
