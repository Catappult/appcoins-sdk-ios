# AppCoins SDK for iOS

The iOS Billing SDK is a simple solution to implement Aptoide billing. It consists of a billing client that allows you to get your products from Aptoide Connect and process the purchase of those items.

The SDK automatically handles transaction reporting to Apple for Core Technology Commission (CTC) calculation, removing this burden from developers. It includes intelligent logic for reporting purchases, refunds, and other transaction events, with region-aware processing that distinguishes which regions require CTC reporting and which do not.

The SDK interface mirrors Apple's StoreKit 2, so if your app already supports StoreKit, migrating to AppCoins SDK only requires prepending `AppCoinsSDK.` to each StoreKit type.

## In Summary

The billing flow in your application with the SDK is as follows:

1. Setup the AppCoins SDK Swift Package;
2. Query your In-App Products;
3. User wants to purchase a product;
4. Application starts the purchase and the SDK handles it, returning the purchase result on completion;
5. Application gives the product to the user.

## Step-by-Step Guide

### Setup

1. **Add AppCoins SDK Swift Package**
   In XCode add the Swift Package from the repo <https://github.com/Catappult/appcoins-sdk-ios.git>.

2. **Add AppCoins SDK Keychain Access Entitlement**
   In order to enable the AppCoins SDK to save the user's AppCoins Wallet information in the keychain, the application will need to concede the SDK Keychain Access entitlements. To do so, follow these steps:
   1. Select your project in the project navigator (left sidebar);
   2. Select your target under "TARGETS";
   3. Go to the "Signing & Capabilities" tab;
   4. Click the "+" button to add a new capability;
   5. Search for "Keychain Sharing" and select it;
   6. Enable the "Keychain Sharing" capability by double-clicking it;
   7. This will automatically write your app's identifier in the "Keychain Groups" text box, you should replace it with "com.aptoide.appcoins-wallet";
   8. Xcode will automatically generate an entitlements file (e.g., YourAppName.entitlements) and add it to your project;

3. **Add AppCoins SDK URL Type**
   To manage redirect deep links for specific payment method integrations, your application must include a URL Type in the info.plist file. To do this, follow these steps:
   1. In the project navigator (left sidebar), select your project.
   2. Under "TARGETS", select your target.
   3. Navigate to the "Info" tab.
   4. Scroll down to the "URL Types" section.
   5. Click the "+" button to add a new URL Type.
   6. Set the URL Scheme to "$(PRODUCT_BUNDLE_IDENTIFIER).iap" and the role to "Editor".

4. **Configure Digital Goods Settings**
   To enable the SDK's automatic transaction reporting for CTC (Core Technology Commission) calculation, you must configure your target to indicate that it sells digital goods. Follow these steps:
   1. In the project navigator (left sidebar), select your project.
   2. Under "TARGETS", select your target.
   3. Navigate to the "Info" tab.
   4. Add a new "MKSellsDigitalGoods" key to your Target Properties.
   5. Set the value to "YES" to enable digital goods transaction reporting.

### Implementation

Now that you have the SDK and necessary permissions set up, you can start making use of its functionalities. Import the SDK module in any file you want to use it: `import AppCoinsSDK`.

1. **Initialize the AppCoins SDK**

   > ⚠️ **CRITICAL:** You MUST call `AppcSDK.initialize()` at every application entry point before any other SDK functionality is used. This method sets up internal SDK processes and is required for the SDK to function properly.

   The SDK must be initialized in your application's entry point methods. Depending on your app's setup, this will be either in SceneDelegate.swift (for iOS 13+) or AppDelegate.swift.

   **SceneDelegate.swift:**
   ```swift
   func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
      AppcSDK.initialize() // REQUIRED
      // ... rest of your code
   }

   func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      AppcSDK.initialize() // REQUIRED
      // ... rest of your code
   }
   ```

   **AppDelegate.swift:**
   ```swift
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      AppcSDK.initialize() // REQUIRED
      // ... rest of your code
   }

   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      AppcSDK.initialize() // REQUIRED
      // ... rest of your code
   }
   ```

2. **Handle the Redirect**

   The SDK requires integration in your application's entry points to properly handle deep links. This ensures that payment redirects work seamlessly.

   Depending on your app's setup, handle deep links either in SceneDelegate.swift (for iOS 13+) or AppDelegate.swift.

   1. `SceneDelegate.swift`

      ```swift
      func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
         AppcSDK.initialize()

         if AppcSDK.handle(redirectURL: URLContexts.first?.url) { return }

         // Your application initialization
         initialize()
      }

      func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contexts = connectionOptions.urlContexts

        AppcSDK.initialize()

        // Your application initialization
        initialize()

        if AppcSDK.handle(redirectURL: contexts.first?.url) { return }
      }
      ```

      Why This Logic?

      - Initialize First in `willConnectTo`
         - When the app launches or restores, UI and dependencies must be set up first.
         - Handling deep links before this can cause issues if SDKs or services aren't ready.

      - Prioritize Deep Links in `openURLContexts`
         - When a deep link arrives while the app is running, handle it immediately and return if processed.
         - This prevents unnecessary re-initialization and ensures the app responds quickly.

   2. `AppDelegate.swift`

      ```swift
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppcSDK.initialize()

        // Your application initialization
        initialize()

        if let url = launchOptions?[.url] as? URL {
          if AppcSDK.handle(redirectURL: url) { return true }
        }
        return true
      }

      func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        AppcSDK.initialize()

        if AppcSDK.handle(redirectURL: url) { return true }

        // Your application initialization
        initialize()
        return true
      }
      ```

3. **Check AppCoins SDK Availability**
   The AppCoins SDK is only available on devices running iOS 17.4 or later and only if the app was not installed through the Apple App Store. Before attempting a purchase, check availability:
   ```swift
   if await AppcSDK.isAvailable() {
       // make purchase
   }
   ```

4. **Query In-App Products**
   Fetch the In-App Products you want to make available by calling `Product.products(for:)` with an array of product identifiers as defined in Aptoide Connect.

   ```swift
   let products = try await Product.products(for: ["gas", "premium"])
   ```

   You can also check the latest transaction or current entitlement for a product directly on the `Product` instance:

   ```swift
   if let result = await product.latestTransaction {
       // user has a previous transaction for this product
   }
   ```

   > ⚠️ **Warning:** You will only be able to query your In-App Products once your application is reviewed and approved on Aptoide Connect.

5. **Purchase an In-App Product**
   Call `purchase()` on a `Product` instance to start a purchase. The method is `async throws` — it throws an `AppCoinsSDKError` on failure and returns a `Product.PurchaseResult` on success or cancellation.

   To associate a user account with the purchase, pass an `appAccountToken`:

   ```swift
   do {
       let result = try await product.purchase(options: [.appAccountToken(userUUID)])

       switch result {
       case .success(let verificationResult):
           switch verificationResult {
           case .verified(let transaction):
               // Give the item to the user, then finish the transaction
               await transaction.finish()
           case .unverified(let transaction, let verificationError):
               // Decide based on your business logic.
               // If not finished, the purchase will be refunded after 24 hours.
           }
       case .pending:
           // Transaction is awaiting an external action (e.g., parental approval)
       case .userCancelled:
           // User dismissed the purchase sheet
       }
   } catch {
       // Handle AppCoinsSDKError
       print("Purchase failed: \(error)")
   }
   ```

6. **Handle Unfinished Transactions on App Launch (CRITICAL)**

   > ⚠️ **CRITICAL:** You MUST process unfinished transactions every time your application starts. Failing to do so will result in users not receiving items they have already paid for. Purchases are automatically refunded after 24 hours if not consumed.

   Unfinished transactions are purchases that have been paid for but not yet consumed. This can happen if the app was closed or crashed mid-purchase, or a network error occurred during completion.

   Use `Transaction.unfinished` — an async stream that yields each pending transaction — during your app's initialization flow:

   ```swift
   func initializeApp() async {
       if await AppcSDK.isAvailable() {
           for await result in Transaction.unfinished {
               switch result {
               case .verified(let transaction):
                   // Give the item to the user based on transaction.productID
                   giveItemToUser(productID: transaction.productID)
                   await transaction.finish()
               case .unverified(let transaction, _):
                   // Handle according to your business logic
                   break
               }
           }
       }
   }
   ```

7. **Listen for Real-Time Transaction Updates**

   `Transaction.updates` is a long-lived async stream that emits every transaction completed during the current app session. Observe it for the lifetime of your app to handle purchases as they complete.

   ```swift
   import AppCoinsSDK

   actor PurchaseManager {
       static let shared = PurchaseManager()

       private init() {
           Task { await observeTransactions() }
       }

       private func observeTransactions() async {
           for await result in Transaction.updates {
               await handle(result: result)
           }
       }

       private func handle(result: VerificationResult<Transaction>) async {
           switch result {
           case .verified(let transaction):
               giveItemToUser(productID: transaction.productID)
               await transaction.finish()
           case .unverified(let transaction, let error):
               // Handle according to your business logic
               break
           }
       }
   }
   ```

8. **Query Transactions**
   You can query the user's transaction history using the following async streams on `Transaction`:

   1. `Transaction.all`

      Yields all transactions the user has performed in your application, ordered by date descending.

      ```swift
      for await result in Transaction.all {
          if case .verified(let transaction) = result {
              print(transaction.productID)
          }
      }
      ```

   2. `Transaction.latest(for: String)`

      Returns the most recent transaction for a specific product identifier.

      ```swift
      if let result = await Transaction.latest(for: "gas") {
          // ...
      }
      ```

   3. `Transaction.unfinished`

      Yields all transactions that have been paid for but not yet consumed. See step 6 for the recommended usage pattern.

      > ⚠️ **CRITICAL:** Call this during app initialization to ensure users receive items from interrupted purchases.

   4. `Transaction.currentEntitlements`

      Equivalent to `Transaction.unfinished` for consumable products — yields all unconsumed purchases.

### Testing

To test the SDK integration during development, you'll need to set the installation source for development builds, simulating that the app is being distributed through Aptoide. This enables the SDK's `isAvailable` method.

Follow these steps:

1. In your target build settings, search for "Marketplaces".
2. Under "Deployment", set the key "Marketplaces" or "Alternative Distribution - Marketplaces" to "com.aptoide.ios.store".

   ![d9d8b6a-image](https://github.com/user-attachments/assets/6b804dde-26c1-4d60-8f1f-42a95c4fdf81)
3. In your scheme, go to the "Run" tab, then navigate to the "Options" tab. In the "Distribution" dropdown, select "com.aptoide.ios.store".

   ![3af7e14-image](https://github.com/user-attachments/assets/f0a4c178-60b2-40c0-9984-183875ed1686)

For more information, please refer to Apple's official documentation: <https://developer.apple.com/documentation/appdistribution/distributing-your-app-on-an-alternative-marketplace#Test-your-app-during-development>

### Testing Both Billing Systems in One Build

To facilitate testing both **Apple Billing** and **Aptoide Billing** within a single build – without generating separate versions of your application – the **AppCoins SDK** includes a deep link mechanism that toggles the SDK's `isAvailable` method between `true` and `false`.

To enable or disable the AppCoins SDK, open your device's browser and enter the following URL:

```text
{domain}.iap://wallet.appcoins.io/default?value={value}
```

Where:

- `domain` – The Bundle ID of your application.
- `value`
  - `true` → Enables the AppCoins SDK for testing.
  - `false` → Disables the AppCoins SDK, allowing Apple Billing to be tested instead.

### Sandbox

To verify the successful setup of your billing integration, we offer a sandbox environment where you can simulate purchases and ensure that your clients can smoothly purchase your products. Documentation on how to use this environment can be found at: [Sandbox](https://docs.connect.aptoide.com/docs/ios-sandbox-environment)

## API Reference

### Product

`Product` represents an in-app product. Use it to query products or trigger a purchase.

**Properties:**

- `id: String` — Unique product identifier as defined in Aptoide Connect. Example: `"gas"`
- `displayName: String` — The product display title. Example: `"Best Gas"`
- `description: String` — The product description. Example: `"Buy gas to fill the tank."`
- `price: Decimal` — The product price in the user's local currency. Example: `0.93`
- `displayPrice: String` — The formatted price label shown to the user. Example: `"€0.93"`
- `type: Product.ProductType` — The product type. Always `.consumable` for AppCoins products.
- `isFamilyShareable: Bool` — Whether the product supports Family Sharing. Always `false`.

**Static methods:**

- `products(for identifiers: [String]) async throws -> [Product]` — Returns the products matching the given identifiers.

**Instance methods:**

- `purchase(options: Set<Product.PurchaseOption> = []) async throws -> Product.PurchaseResult` — Starts the purchase flow for this product.

**Async computed properties:**

- `latestTransaction: VerificationResult<Transaction>?` — The most recent transaction for this product.
- `currentEntitlement: VerificationResult<Transaction>?` — The current unconsumed entitlement for this product.

### Product.PurchaseResult

The result of a `purchase()` call.

- `.success(verificationResult: VerificationResult<Transaction>)` — Purchase completed. Check the verification result before delivering the item.
- `.pending` — Transaction is awaiting an external action (e.g., parental approval).
- `.userCancelled` — The user dismissed the purchase sheet.

Errors (network, system, availability) are thrown rather than returned as a case.

### Product.PurchaseOption

Options you can pass to `purchase(options:)`.

- `.appAccountToken(_ token: UUID)` — Associates a UUID with the purchase (e.g., to link it to a specific user account). Accessible later via `Transaction.appAccountToken`.

### Transaction

`Transaction` represents a completed in-app purchase. Use it to query transaction history or consume purchases.

**Properties:**

- `id: UInt64` — Stable numeric identifier derived from the AppCoins transaction UID. Compatible with systems expecting a numeric ID.
- `transactionUID: String` — The original AppCoins transaction UID, as shown in the Catappult dashboard.
- `productID: String` — The product identifier that was purchased.
- `purchaseDate: Date` — The date and time the purchase was made.
- `appAccountToken: UUID?` — The account token passed during purchase via `Product.PurchaseOption.appAccountToken`.
- `revocationDate: Date?` — Always `nil` (AppCoins does not support revocation).
- `revocationReason: Transaction.RevocationReason?` — Always `nil`.
- `ownershipType: Transaction.OwnershipType` — Always `.purchased` (Family Sharing is not supported).

**Static async streams:**

- `Transaction.all` — Yields all transactions for the app, ordered by date descending.
- `Transaction.unfinished` — Yields all transactions that have been paid but not yet consumed.
- `Transaction.currentEntitlements` — Equivalent to `Transaction.unfinished` for consumables.
- `Transaction.updates` — Long-lived stream that emits transactions as they complete during the app session.

**Static methods:**

- `Transaction.latest(for productID: String) async -> VerificationResult<Transaction>?` — Returns the most recent transaction for the given product.

**Instance methods:**

- `finish() async` — Consumes the transaction. Call this after delivering the purchased item to the user.

### VerificationResult\<Transaction\>

Wraps a `Transaction` with its verification status.

- `.verified(Transaction)` — The transaction signature was validated locally. Safe to deliver the item.
- `.unverified(Transaction, AppCoinsSDKError)` — Signature validation failed. Apply your business logic to decide whether to deliver the item (unfinished transactions are refunded after 24 hours).

### AppcSDK

Handles SDK lifecycle and deep link routing.

**Methods:**

- `initialize()` — **REQUIRED.** Sets up internal SDK processes. Must be called at every application entry point.
- `isAvailable() async -> Bool` — Returns `true` if the SDK is available (iOS 17.4+, not installed via the Apple App Store).
- `handle(redirectURL: URL?) -> Bool` — Routes deep links for payment redirects. Returns `true` if the SDK handled the URL.
- `configure(locale: Storefront.Locale?, marketplace: Storefront.Marketplace?)` — Overrides the default storefront locale and marketplace. Only takes effect when `AppCoinsDevTools` are enabled.

### Storefront

Represents the storefront locale and marketplace used by the SDK.

- `Storefront.Locale` — ISO 3166-1 alpha-3 country codes (e.g., `Storefront.Locale.PRT`).
- `Storefront.Marketplace` — `.aptoide` or `.apple`.

### AppCoinsSDKError

The error type thrown by SDK methods.

- `networkError` — Network connectivity issues.
- `systemError` — Internal AppCoins system errors.
- `notEntitled` — The host app does not have the required entitlements configured.
- `productUnavailable` — The requested product is not available.
- `purchaseNotAllowed` — The user was not permitted to perform the purchase.
- `unknown` — Other unclassified errors.

All cases carry a description string accessible via `error.description`.
