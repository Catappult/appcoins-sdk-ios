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
    rootViewController.present(purchaseViewController, animated: true, completion: nil)
}

class PurchaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let bottomSheetView = BottomSheetView()
        let content: () -> UIView = {
            return bottomSheetView.toUIView()
        }
        let wrapperView = BottomSheetWrapperView(content: content)
        self.view.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            wrapperView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5)
        ])
    }
}

struct BottomSheetView: View {
    var body: some View {
        VStack {
            Text("This is the bottom sheet")
        }
        .frame(height: 300)
        .background(Color.green)
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
        self.backgroundColor = .clear
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



