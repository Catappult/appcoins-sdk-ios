# AppCoins SDK for iOS

The iOS Billing SDK implements AppCoins billing. It provides a billing client for fetching products from Aptoide Connect and processing purchases.

The SDK automatically handles transaction reporting to Apple for Core Technology Commission (CTC) calculation, removing this burden from developers. It includes intelligent logic for reporting purchases, refunds, and other transaction events, with region-aware processing that distinguishes which regions require CTC reporting and which do not.

The SDK interface mirrors Apple's StoreKit 2, so if your app already supports StoreKit, migrating to AppCoins SDK only requires prepending `AppCoinsSDK.` to each StoreKit type.

> For more detailed information, refer to the official documentation at: https://docs.connect.aptoide.com/docs/in-app-purchases-integration-sdk

## In Summary

The billing flow in your application with the SDK is as follows:

1. Setup the AppCoins SDK Swift Package and configure Xcode;
2. Initialize the SDK at every application entry point;
3. Check SDK availability before attempting a purchase;
4. Query your In-App Products;
5. User wants to purchase a product;
6. Application starts the purchase and the SDK handles it, returning the purchase result and verification data on completion;
7. Application delivers the product to the user and finishes the transaction.

## Step-by-Step Guide

### Setup

1. **Add AppCoins SDK Swift Package**

   In Xcode, add the Swift Package from the repository <https://github.com/Catappult/appcoins-sdk-ios.git>. When prompted for a version rule, select **Up to Next Major Version** starting from the latest major version (e.g. `5.0.0`). This ensures you automatically receive patch and minor updates while avoiding breaking changes from a future major release.

2. **Add Keychain Sharing Capability**

   The SDK stores wallet information in the keychain. Add Keychain Sharing and set the group identifier exactly as shown below:

   1. Select your project in the **Project Navigator** (left sidebar);
   2. Select your target under **TARGETS**;
   3. Go to the **Signing & Capabilities** tab;
   4. Click the **+** button to add a new capability;
   5. Search for **Keychain Sharing** and select it;
   6. In the **Keychain Groups** field, replace the default value with exactly `com.aptoide.appcoins-wallet`;
   7. Xcode will automatically generate an entitlements file and add it to your project.

   > ⚠️ **Warning:** The Keychain Sharing group must be set to exactly `com.aptoide.appcoins-wallet`. Any other value will result in an `AppCoinsSDKError.notEntitled` error at runtime.

3. **Add URL Scheme**

   The SDK requires a URL scheme to handle payment redirect deep links. To add it:

   1. In the **Project Navigator**, select your project;
   2. Under **TARGETS**, select your target;
   3. Navigate to the **Info** tab;
   4. Scroll down to the **URL Types** section;
   5. Click the **+** button to add a new URL Type;
   6. Set the URL Scheme to `$(PRODUCT_BUNDLE_IDENTIFIER).iap` and the Role to `Editor`.

4. **Add `MKSellsDigitalGoods` to Info.plist**

   To enable CTC transaction reporting, add the following key to your `Info.plist`:

   - Key: `MKSellsDigitalGoods`
   - Value: `YES` (Boolean)

### Implementation

Once setup is complete, import the SDK module in any file where you want to use it:

```swift
import AppCoinsSDK
```

#### 1. Initialize the AppCoins SDK

> ⚠️ **CRITICAL:** Call `AppcSDK.initialize()` at every application entry point before any other SDK functionality is used. This method sets up internal SDK processes and is required for the SDK to function correctly.

Depending on your app's setup, initialize the SDK in `SceneDelegate.swift` (iOS 13+) or `AppDelegate.swift`.

**SceneDelegate.swift:**

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    AppcSDK.initialize() // REQUIRED

    // Your application initialization
    initialize()

    let contexts = connectionOptions.urlContexts
    if AppcSDK.handle(redirectURL: contexts.first?.url) { return }
}

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    AppcSDK.initialize() // REQUIRED

    if AppcSDK.handle(redirectURL: URLContexts.first?.url) { return }

    // Your application initialization
    initialize()
}
```

**AppDelegate.swift:**

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    AppcSDK.initialize() // REQUIRED

    // Your application initialization
    initialize()

    if let url = launchOptions?[.url] as? URL {
        if AppcSDK.handle(redirectURL: url) { return true }
    }
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    AppcSDK.initialize() // REQUIRED

    if AppcSDK.handle(redirectURL: url) { return true }

    // Your application initialization
    initialize()
    return true
}
```

**Why this ordering matters:**

- In the "launch" methods (`willConnectTo` / `didFinishLaunchingWithOptions`): initialize the SDK and set up your app's dependencies first, then check for a deep link. Processing a deep link before the app is ready can cause issues if required services are not yet available.
- In the "open URL" methods (`openURLContexts` / `open url`): handle the deep link immediately and return early if the SDK processed it. This prevents unnecessary re-initialization and ensures the app responds quickly to payment redirects.

#### 2. Handle the Redirect

`AppcSDK.handle(redirectURL:)` is already shown in the entry point examples above. It processes payment redirect deep links and returns `true` if the SDK handled the URL. Always call it after `AppcSDK.initialize()` and return early when it returns `true`.

#### 3. Check AppCoins SDK Availability

`isAvailable()` returns `true` on iOS 17.4+ for any install source that is not the Apple App Store or TestFlight. Before attempting a purchase, check availability:

```swift
if await AppcSDK.isAvailable() {
    // proceed with AppCoins billing
} else {
    // fall back to Apple StoreKit
}
```

#### 4. Query In-App Products

Fetch the In-App Products you want to offer by passing an array of SKU identifier strings to `Product.products(for:)`.

```swift
do {
    let products = try await Product.products(for: ["gas", "premium_pack"])
} catch {
    // handle error
}
```

> ⚠️ **Warning:** In-App Products can only be queried after your application has been reviewed and approved on Aptoide Connect.

#### 5. Purchase an In-App Product

Call `purchase()` on a `Product` instance. The SDK handles all purchase logic and returns a `Product.PurchaseResult`. Errors are thrown rather than returned as a result case — wrap the call in a `do/catch` block.

On success, the result contains a `VerificationResult<Transaction>`:

- `.verified` — the transaction signature was validated locally; deliver the item and call `transaction.finish()`.
- `.unverified` — validation failed; apply your business logic. If you do not call `transaction.finish()`, the purchase will be automatically refunded after 24 hours.

You can optionally associate a UUID with a purchase using `Product.PurchaseOption.appAccountToken(_:)` — for example, to link the transaction to a specific user account.

```swift
do {
    let result = try await product.purchase()

    switch result {
    case .success(let verificationResult):
        switch verificationResult {
        case .verified(let transaction):
            // Deliver the item to the user
            giveItemToUser(productID: transaction.productID)
            // Mark the transaction as finished
            await transaction.finish()
        case .unverified(let transaction, let verificationError):
            // Apply your business logic for unverified transactions
            print("Unverified transaction: \(verificationError.description)")
        }
    case .pending:
        // Transaction is awaiting external action
        break
    case .userCancelled:
        // User dismissed the payment sheet
        break
    }
} catch {
    // Handle AppCoinsSDKError
    if let sdkError = error as? AppCoinsSDKError {
        print(sdkError.description)
    }
}
```

To associate a purchase with a user account token:

```swift
let result = try await product.purchase(options: [.appAccountToken(userUUID)])
```

#### 6. Handle Unfinished Transactions on App Launch

> ⚠️ **CRITICAL:** Iterate over `Transaction.unfinished` every time your application starts. Users who paid but did not receive their item — due to a crash, force-quit, or network error during purchase — will not receive it otherwise. Unfinished transactions are automatically refunded after 24 hours if not consumed.

`Transaction.unfinished` is an `AsyncStream` that emits all paid-but-unconsumed transactions. Iterate over it during your app's initialization flow, after confirming SDK availability.

```swift
func processUnfinishedTransactions() async {
    guard await AppcSDK.isAvailable() else { return }

    for await verificationResult in Transaction.unfinished {
        switch verificationResult {
        case .verified(let transaction):
            // Deliver the item and finish the transaction
            giveItemToUser(productID: transaction.productID)
            await transaction.finish()
        case .unverified(let transaction, let verificationError):
            // Apply your business logic
            print("Unverified unfinished transaction: \(verificationError.description)")
        }
    }
}
```

Call this function from your app's startup sequence, for example in a `ViewModel` or an `@main` `App` struct `init`.

#### 7. Query Transactions

The SDK provides several ways to query the user's transaction history.

**All transactions (`Transaction.all`)**

An `AsyncStream` of all transactions for your app, newest first:

```swift
for await verificationResult in Transaction.all {
    // process each transaction
}
```

**Latest transaction for a product (`Transaction.latest(for:)`)**

Returns the most recent transaction for a specific product identifier:

```swift
if let verificationResult = await Transaction.latest(for: "gas") {
    // process transaction
}
```

**Unfinished transactions (`Transaction.unfinished`)**

An `AsyncStream` of paid but unconsumed transactions. See step 6 for the full implementation pattern.

### Testing

To test the SDK integration during development, you need to simulate that the app is being distributed through Aptoide. This enables the SDK's `isAvailable` method.

1. In your target's build settings, search for "Marketplaces";
2. Under **Deployment**, set the **Marketplaces** (or **Alternative Distribution - Marketplaces**) key to `com.aptoide.ios.store`;

   ![d9d8b6a-image](https://github.com/user-attachments/assets/6b804dde-26c1-4d60-8f1f-42a95c4fdf81)
3. In your scheme, go to the **Run** tab, then the **Options** tab. In the **Distribution** dropdown, select `com.aptoide.ios.store`.

   ![3af7e14-image](https://github.com/user-attachments/assets/f0a4c178-60b2-40c0-9984-183875ed1686)

For more information, refer to Apple's official documentation: <https://developer.apple.com/documentation/appdistribution/distributing-your-app-on-an-alternative-marketplace#Test-your-app-during-development>

### Testing Both Billing Systems in One Build

To switch between AppCoins billing and Apple billing on a real device without rebuilding, use these deep links from Safari:

| Action | Deep link |
|---|---|
| Force AppCoins billing | `{domain}.iap://wallet.appcoins.io/default/mode?value=appcoins` |
| Force Apple billing | `{domain}.iap://wallet.appcoins.io/default/mode?value=apple` |
| Restore automatic detection | `{domain}.iap://wallet.appcoins.io/default/mode?value=automatic` |
| Show current mode | `{domain}.iap://wallet.appcoins.io/default/info` |

Replace `{domain}` with your app's bundle identifier. The mode change persists across launches. The `info` deep link shows a 3-second overlay with the active mode.

> ⚠️ **Warning:** Mode overrides have no effect on builds installed from the Apple App Store, to prevent misuse.

### Sandbox

To verify the successful setup of your billing integration, we offer a sandbox environment where you can simulate purchases and ensure that your users can smoothly purchase your products. Documentation on how to use this environment can be found at: [Sandbox](https://docs.connect.aptoide.com/docs/ios-sandbox-environment)

You can retrieve the current testing wallet address using:

```swift
if let walletAddress = await Sandbox.getTestingWalletAddress() {
    print("Testing wallet: \(walletAddress)")
}
```

## API Reference

### Product

`Product` represents an in-app product. Use it to fetch products from Aptoide Connect or to initiate a purchase.

**Static Methods:**

- `Product.products(for: [String]) async throws -> [Product]` — fetches products by their SKU identifier strings.

**Instance Methods:**

- `product.purchase(options: Set<Product.PurchaseOption>) async throws -> Product.PurchaseResult` — initiates a purchase for the product.

**Properties:**

- `id: String` — unique product identifier (SKU). Example: `gas`
- `displayName: String` — the product display title. Example: `Best Gas`
- `description: String` — the product description. Example: `Buy gas to fill the tank.`
- `price: Decimal` — the product price as a decimal number.
- `displayPrice: String` — the formatted price label shown to the user. Example: `€0.93`
- `type: Product.ProductType` — always `.consumable` for AppCoins products.
- `isFamilyShareable: Bool` — always `false` for AppCoins products.

**Async Properties:**

- `product.latestTransaction: VerificationResult<Transaction>?` — the most recent transaction for this product.
- `product.currentEntitlement: VerificationResult<Transaction>?` — the current unfinished transaction for this product, if any.

### Product.PurchaseResult

The result returned by `product.purchase()`. Errors are thrown rather than returned as a case.

- `.success(verificationResult: VerificationResult<Transaction>)` — purchase completed; inspect the verification result before delivering the item.
- `.pending` — the transaction is awaiting an external action.
- `.userCancelled` — the user dismissed the payment sheet.

### Product.PurchaseOption

Options that can be passed to `product.purchase(options:)`.

- `.appAccountToken(_ token: UUID)` — associates a UUID (e.g. a user account identifier) with the purchase. Accessible later via `transaction.appAccountToken`.

### Transaction

`Transaction` represents a completed in-app transaction.

**Static Streams:**

- `Transaction.all` — `AsyncStream` of all transactions for the app, newest first.
- `Transaction.unfinished` — `AsyncStream` of paid but unconsumed transactions.
- `Transaction.updates` — `AsyncStream` that emits transactions delivered outside the normal purchase flow (e.g. Ask to Buy approvals, offer code redemptions, or purchases completed on another device).
- `Transaction.currentEntitlements` — alias for `Transaction.unfinished`.

**Static Methods:**

- `Transaction.latest(for productID: String) async -> VerificationResult<Transaction>?` — returns the most recent transaction for the given product identifier.

**Instance Methods:**

- `transaction.finish() async` — marks the transaction as consumed. Call this after delivering the item to the user.

**Properties:**

- `id: String` — unique transaction identifier. Note: this is a `String`, not a `UInt64` as in StoreKit.
- `productID: String` — the SKU identifier of the purchased product.
- `purchaseDate: Date` — the date and time the purchase was made.
- `appAccountToken: UUID?` — the account token associated with the purchase, if one was provided at purchase time.

### VerificationResult\<Transaction\>

A generic enum wrapping a `Transaction` with its validation status.

- `.verified(Transaction)` — the transaction signature was validated locally; it is safe to deliver the item.
- `.unverified(Transaction, AppCoinsSDKError)` — signature validation failed; apply your business logic. If you do not call `transaction.finish()`, the purchase will be automatically refunded after 24 hours.

### AppcSDK

Provides general-purpose SDK methods for initialization, availability checks, and deep link handling.

**Methods:**

- `AppcSDK.initialize()` — **Required.** Sets up internal SDK processes. Must be called at every application entry point before any other SDK call.
- `AppcSDK.isAvailable() async -> Bool` — returns `true` on iOS 17.4+ for any install source except the Apple App Store and TestFlight. Always returns `true` on the Simulator (`AppDistributor` cannot be queried there).
- `AppcSDK.handle(redirectURL: URL?) -> Bool` — handles payment redirect deep links. Returns `true` if the SDK processed the URL.

### AppCoinsSDKError

The error type thrown or returned by SDK operations. Every case has a `.description: String` property with a human-readable explanation.

- `.networkError` — a network connectivity issue prevented the operation.
- `.systemError` — an internal AppCoins system error occurred.
- `.notEntitled` — the app is missing the required Keychain Sharing entitlement (`com.aptoide.appcoins-wallet`).
- `.productUnavailable` — the product was not found or has not been approved in Aptoide Connect.
- `.purchaseNotAllowed` — the user is not permitted to make purchases (e.g. parental controls, regional restriction).
- `.unknown` — an unclassified error occurred.
