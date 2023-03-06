public struct AppCoinsSDK {
    
    static public func isWalletInstalled() -> Bool { return WalletUtils.isWalletInstalled() }
    
    static public func getWalletAddress() -> String { return WalletUtils.getWalletAddress() }
    
}
