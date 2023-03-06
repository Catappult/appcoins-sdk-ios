//
//  AppCoinsBilling.swift
//  appcoins-sdk
//
//  Created by aptoide on 01/03/2023.
//

import Foundation

public class AppCoinsBilling {
    
    private let BillingService: BillingService = BillingClient()
    private let base64DecodedPublicKey: Data
    
    public init(base64DecodedPublicKey: Data) {
        self.base64DecodedPublicKey = base64DecodedPublicKey
    }
    
    public func queryPurchases(skuType: String) -> Void { // PurchasesResult {
        do {
            
            if WalletUtils.isWalletInstalled() {
                
                let packageName = "com.appcoins.trivialdrivesample" // BuildConfiguration.packageName
                let walletAddress = WalletUtils.getWalletAddress()
                let walletSignature = WalletUtils.getWalletSignature()
                
                let purchasesResult = try BillingService.getPurchases(packageName: packageName, walletAddress: walletAddress, walletSignature: walletSignature, type: "inapp")
                
//                if purchasesResult.getResponseCode() != ResponseCode.OK.rawValue {
//                    return PurchasesResult(purchases: [], responseCode: purchasesResult.getResponseCode())
//                }
//
//                var invalidPurchases = [Purchase]()
//
//                for purchase in purchasesResult.getPurchases() {
//                    let purchaseData = purchase.getOriginalJson()
//                    let decodeSignature = purchase.getSignature()
//
//                    if !verifyPurchase(purchaseData: purchaseData, decodeSignature: decodeSignature) {
//                        invalidPurchases.append(purchase)
//                        return PurchasesResult(purchases: [], responseCode: ResponseCode.ERROR.rawValue)
//                    }
//                }
//
//                if !invalidPurchases.isEmpty {
//                    var currentPurchases = purchasesResult.getPurchases()
//                    currentPurchases = currentPurchases.filter { !invalidPurchases.contains($0) }
//                    purchasesResult.setPurchases(purchases: currentPurchases)
//                }
//
//                return purchasesResult
            }
        } catch {
            print(error)
            
//            return PurchasesResult(purchases: [], responseCode: ResponseCode.SERVICE_UNAVAILABLE.rawValue)
        }
    }
    
//    public func verifyPurchase(purchaseData: String, decodeSignature: Data) -> Bool {
//        return Security.verifyPurchase(base64DecodedPublicKey: base64DecodedPublicKey, signedData: purchaseData, decodedSignature: decodeSignature)
//    }
//
//    public func querySkuDetailsAsync(skuDetailsParams: SkuDetailsParams, onSkuDetailsResponseListener: SkuDetailsResponseListener) {
//        let skuDetailsAsync = SkuDetailsAsync(skuDetailsParams: skuDetailsParams, skuDetailsResponseListener: onSkuDetailsResponseListener, repository: repository)
//        let t = Thread(target: skuDetailsAsync, selector: #selector(SkuDetailsAsync.run), object: nil)
//        t.start()
//    }
//
//    public func consumeAsync(purchaseToken: String, listener: ConsumeResponseListener) {
//        let consumeAsync = ConsumeAsync(token: purchaseToken, listener: listener, repository: repository)
//        let t = Thread(target: consumeAsync, selector: #selector(ConsumeAsync.run), object: nil)
//        t.start()
//    }
//
//    public func launchBillingFlow(params: BillingFlowParams, payload: String) throws -> LaunchBillingFlowResult {
//        do {
//            let result = try repository.launchBillingFlow(skuType: params.getSkuType(), sku: params.getSku(), payload: payload)
//            return result
//        } catch {
//            print(error.localizedDescription)
//            throw ServiceConnectionException(message: error.localizedDescription)
//        }
//    }
//
//    public func isReady() -> Bool {
//        return repository.isReady()
//    }
}
