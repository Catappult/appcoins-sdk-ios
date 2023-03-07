import SwiftUI
import UIKit

public struct AppCoinsSDK {
    
    static public func isWalletInstalled() -> Bool { return WalletUtils.isWalletInstalled() }
    
    static public func getWalletAddress() -> String { return WalletUtils.getWalletAddress() }
    
    static public func purchase() { presentPurchase() }
}

public func presentPurchase() {
    guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
        return
    }
    let purchaseViewController = PurchaseViewController()
    purchaseViewController.modalPresentationStyle = .overFullScreen
    rootViewController.present(purchaseViewController, animated: false, completion: nil)
}

class PurchaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a background view to the top half of the screen
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        self.view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5)
        ])
        
        // Add a tap gesture recognizer to dismiss the bottom sheet
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPurchase))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add the bottom sheet view
        let bottomSheetView = BottomSheetView()
        let content: () -> UIView = {
            return bottomSheetView.toUIView()
        }
        let wrapperView = BottomSheetWrapperView(content: content)
        self.view.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    @objc private func dismissPurchase() {
        self.dismiss(animated: false, completion: nil)
    }
}


struct BottomSheetView: View {
    var body: some View {
        ZStack {
            ColorsUi.APC_DarkBlue
            
            Text("This is the bottom sheet")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .cornerRadius(13, corners: [.topLeft, .topRight])
    }
}

extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

class BottomSheetWrapperView<Content: UIView>: UIView {
    let contentView: Content
    
    init(content: @escaping () -> Content) {
        self.contentView = content()
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
//        self.backgroundColor = .clear
        self.addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}



