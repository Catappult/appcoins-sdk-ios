import SwiftUI
import UIKit

public struct AppCoinsSDK {
    
    static public func purchase() {
        if WalletUtils.isWalletInstalled() {
            print(WalletUtils.getWalletAddress())
            SDKViewController.presentPurchase()
        }
    }
}
