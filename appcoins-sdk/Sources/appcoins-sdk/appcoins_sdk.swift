public struct appcoins_sdk {
    public private(set) var text = "Hello, World!"

    public func isWalletInstalled() -> Bool { return WalletUtils.isWalletInstalled() }
    
    public func getWalletAddress() -> String { return WalletUtils.getWalletAddress() }
    
    public init() {
    }
}
