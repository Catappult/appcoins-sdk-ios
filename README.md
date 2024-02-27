# AppCoins SDK for iOS

The iOS Billing SDK is a simple solution to implement Catappult billing. It consists of a Billing client that uses an AppCoins Wallet integration and allows you to get your products from Catappult and process the purchase of those items.

## In Summary

The billing flow in your application with the SDK is as follows:

1. Setup the AppCoins SDK Swift Package;
2. Query your In-App Products;
3. User wants to purchase a product;
4. Application starts the purchase and the SDK handles it, returning the purchase status and validation data on completion;
5. Application gives the product to the user.

## Step-by-Step Guide

### Setup

1. **Add AppCoins SDK Swift Package**  
   In XCode add the Swift Package from the repo <https://github.com/Catappult/appcoins-sdk-ios.git>.

2. **Add AppCoins SDK Keychain Access Entitlement**  
   In order to enable the AppCoins SDK to save the user’s AppCoins Wallet information in the keychain, the application will need to concede the SDK Keychain Access entitlements. To do so, follow these steps:
   1. Select your project in the project navigator (left sidebar);
   2. Select your target under "TARGETS";
   3. Go to the "Signing & Capabilities" tab;
   4. Click the "+" button to add a new capability;
   5. Search for "Keychain Sharing" and select it;
   6. Enable the "Keychain Sharing" capability by double-clicking it;
   7. This will automatically write your app’s identifier in the "Keychain Groups" text box, you should replace it with “com.aptoide.appcoins-wallet“;
   8. Xcode will automatically generate an entitlements file (e.g., YourAppName.entitlements) and add it to your project;

3. **Add StoreKit External Purchase Entitlement**  
   To comply with Apple's rules for Alternative Payment Service Providers the application will need to add the StoreKit External Purchase Entitlement. To do so, follow these steps:
   1. Select your project in the project navigator (left sidebar);
   2. Select your target under "TARGETS";
   3. Go to the "Signing & Capabilities" tab;
   4. Click the "+" button to add a new capability;
   5. Search for "StoreKit External Purchase" and select it;
   6. Enable the "StoreKit External Purchase" capability by double-clicking it;

4. **Add StoreKit External Purchase Property List Key**  
   To comply with Apple's rules for Alternative Payment Service Providers the application will need to add a Property List Key (SKExternalPurchase) indicating the countries where your application supports external purchases. To do this, follow these steps:

   1. In the project navigator (left sidebar), select your project.
   2. Under "TARGETS", select your target.
   3. Navigate to the "Info" tab.
   4. If it doesn't already exist, add a new property called "SKExternalPurchase".
   5. Click the "+" button to add a country to the list.

   The list of EU country codes to add if your app supports alternative payment processing for all countries in the European Union is the following:

   ```xml
   <key>SKExternalPurchase</key>
   	<array>
   		<string>at</string>
   		<string>be</string>
   		<string>bg</string>
   		<string>hr</string>
   		<string>cy</string>
   		<string>cz</string>
   		<string>dk</string>
   		<string>ee</string>
   		<string>fi</string>
   		<string>fr</string>
   		<string>de</string>
   		<string>gr</string>
   		<string>hu</string>
   		<string>ie</string>
   		<string>it</string>
   		<string>lv</string>
   		<string>lt</string>
   		<string>lu</string>
   		<string>mt</string>
   		<string>nl</string>
   		<string>pl</string>
   		<string>pt</string>
   		<string>ro</string>
   		<string>sk</string>
   		<string>si</string>
   		<string>es</string>
   		<string>se</string>
   	</array>
   ```

5. **Add AppCoins SDK URL Type**  
   To manage redirect deep links for specific payment method integrations, your application must include a URL Type in the info.plist file. To do this, follow these steps:
   1. In the project navigator (left sidebar), select your project.
   2. Under "TARGETS", select your target.
   3. Navigate to the "Info" tab.
   4. Scroll down to the "URL Types" section.
   5. Click the "+" button to add a new URL Type.
   6. Set the URL Scheme to "$(PRODUCT_BUNDLE_IDENTIFIER).iap" and the role to "Editor".

6. **Add AppCoins Wallet Queried URL Scheme**  
   To enable the SDK to detect the presence of the AppCoins Wallet app, allowing users to make payments using their Wallet, you need to include the AppCoins Wallet URL scheme in your list of queried URL schemes. Follow these steps to achieve this:
   1. In the project navigator (left sidebar), select your project.
   2. Under "TARGETS", select your target.
   3. Navigate to the "Info" tab.
   4. If it doesn't already exist, add a new property called "Queried URL Schemes".
   5. To add the AppCoins Wallet URL scheme, click the "+" button.
   6. Set the URL Scheme field to "com.aptoide.appcoins-wallet".

### Implementation

Now that you have the SDK and necessary permissions set-up you can start making use of its functionalities. To do so you must import the SDK module in any files you want to use it by calling the following: `import AppCoinsSDK`.

1. **Handle the Redirect**  
   In your `SceneDelegate.swift` file (or in another entry point your application might have), you need to handle potential payment redirects when the application is brought to the foreground.
   ```swift Swift
   func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
       if AppcSDK.handle(redirectURL: URLContexts.first?.url) { return }
       
       // the rest of your code
   }
   ```
   **🚧 It is important that the `AppcSDK.handle` method precedes the rest of your code.**

2. **Check AppCoins SDK Availability**  
   The AppCoins SDK will only be available on devices in the European Union with an iOS version equal to or higher than 17.4. Therefore, before attempting any purchase, you should check if the SDK is available by calling `AppcSDK.isAvailable`.
   ```swift
   if await AppcSDK.isAvailable() {
   	// make purchase
   }
   ```

3. **Query In-App Products**  
   You should start by getting the In-App Products you want to make available to the user. You can do this by calling `Product.products`.

   This method can either return all of your Cattapult In-App Products or a specific list.

   1. `Product.products()`

      Returns all application Cattapult In-App Products:

      ```swift
      let products = try await Product.products()
      ```
   2. `Product.products(for: [String])`

      Returns a specific list of Cattapult In-App Products:

      ```swift
      let products = try await Product.products(for: ["gas"])
      ```

4. **Purchase In-App Product**  
   To purchase an In-App Product you must call the function `purchase()` on a Product object. The SDK will handle all of the purchase logic for you and it will return you on completion the result of the purchase. This result can be either `.success(let verificationResult)`, `.pending`, `.userCancelled` or `.failed(let error)`.

   In case of success the application will verify the transaction’s signature locally. After this verification you should handle its result:  
          – If the purchase is verified you should consume the item and give it to the user:  
          – If it is not verified you need to make a decision based on your business logic, you either still consume the item and give it to the user, or otherwise the purchase will not be acknowledged and we will refund the user in 24 hours.

   In case of failure you can deal with different types of error in a switch statement. Every error returned by the SDK is of type `AppCoinsSDKError` and it is described later in this document.

   You can also pass a Payload to the purchase method in order to associate some sort of information with a specific purchase. You can use this for example to associate a specific user with a Purchase: `gas.purchase(payload: "User123")`.  
   <br/>

   ```swift
   let result = await products?.first?.purchase()
               
   switch result {
       case .success(let verificationResult):
            switch verificationResult {
                  case .verified(let purchase):
                       // consume the item and give it to the user
                       try await purchase.finish()
                  case .unverified(let purchase, let verificationError):
                       // deal with unverified transactions
            }
       case .pending: // transaction is not finished
       case .userCancelled: // user cancelled the transaction
       case .failed(let error): // deal with any possible errors
   }
   ```

5. **Query Purchases**  
   You can query the user’s purchases by using one of the following methods:

   1. `Purchase.all`

      This method returns all purchases that the user has performed in your application.

      ```swift
      let purchases = try await Purchase.all()
      ```
   2. `Purchase.latest(sku: String)`

      This method returns the latest user purchase for a specific In-App Product.

      ```swift
      let purchase = try await Purchase.latest(sku: "gas")
      ```
   3. `Purchase.unfinished`

      This method returns all of the user’s unfinished purchases in the application. An unfinished purchase is any purchase that has neither been acknowledged (verified by the SDK) nor consumed. You can use this method for consuming any unfinished purchases.

      ```swift
      let purchases = try await Purchase.unfinished()
      ```

## Extra Steps

### Add Localization

In order to add translations for different localizations, the application will need to add a Mixed Localizations permission. Follow these steps:

1. In the Project Navigator (left sidebar), locate the "Info.plist" file. It is typically in the root folder of your project.
2. Double-click on "Info.plist" to open it in the property list editor.
3. Add a new row - Right-click on any existing key-value pair in the property list editor and choose "Add Row," or use the "+" button at the top of the editor.
4. Set the key to `CFBundleAllowMixedLocalizations`.
5. Set the type of the new key to Boolean.
6. Set the value to `YES` to allow mixed localizations.

## Classes Definition and Properties

The SDK integration is based on four main classes of objects that handle its logic:

### Product

`Product` represents an in-app product. You can use it to either statically query products or use a specific instance to perform a purchase.

**Properties:**

- `sku`: String - Unique product identifier. Example: gas
- `title`: String - The product display title. Example: Best Gas
- `description`: String? - The product description. Example: Buy gas to fill the tank.
- `priceCurrency`: String - The user’s geolocalized currency. Example: EUR
- `priceValue`: String - The value of the product in the specified currency. Example: 0.93
- `priceLabel`: String - The label of the price displayed to the user. Example: €0.93
- `priceSymbol`: String - The symbol of the geolocalized currency. Example: €

### Purchase

`Purchase` represents an in-app purchase. You can use it to statically query the user’s purchases or use a specific instance to consume the respective purchase.

**Properties:**

- `uid`: String - Unique purchase identifier. Example: catappult.inapp.purchase.ABCDEFGHIJ1234
- `sku`: String - Unique identifier for the product that was purchased. Example: gas
- `state`: String - The purchase state can be one of three: PENDING, ACKNOWLEDGED, and CONSUMED. Pending purchases are purchases that have neither been verified by the SDK nor have been consumed by the application. Acknowledged purchases are purchases that have been verified by the SDK but have not been consumed yet. Example: CONSUMED
- `orderUid`: String - The orderUid associated with the purchase. Example: ZWYXGYZCPWHZDZUK4H
- `payload`: String - The developer Payload. Example: 707048467.998992
- `created`: String - The creation date for the purchase. Example: 2023-01-01T10:21:29.014456Z

### AppcSDK

This class is responsible for general purpose methods such as handling redirects or checking if the SDK is available.

### AppCoinsSDKError

The error enum that can be returned by the SDK while performing any action.

**Possible errors:**

- `networkError`: Network related errors;
- `systemError`: Internal APPC system errors;
- `notEntitled`: The host app does not have proper entitlements configured;
- `productUnavailable`: The product is not available;
- `purchaseNotAllowed`: The user was not allowed to perform the purchase;
- `unknown`: Other errors.
