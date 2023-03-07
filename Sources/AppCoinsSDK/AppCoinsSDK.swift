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
        
        // Add the bottom sheet view
        let bottomSheetView = BottomSheetView(dismiss: self.dismissPurchase)
        let content: () -> UIView = {
            return bottomSheetView.toUIView()
        }
        let wrapperView = BottomSheetWrapperView(content: content)
        self.view.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func dismissPurchase() {
        self.dismiss(animated: false, completion: nil)
    }
}


struct BottomSheetView: View {
    
    var dismiss: () -> Void
    
    var body: some View {
        VStack {
            VStack{}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture { dismiss() }
            
            ZStack {
                ColorsUi.APC_DarkBlue
                
                Text("This is the bottom sheet")
                    .foregroundColor(ColorsUi.APC_White)
            }
            .onTapGesture { dismiss() }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 2))
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .background(Color.black.opacity(0.3).ignoresSafeArea())
            .ignoresSafeArea()
        }.ignoresSafeArea()
        
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
        self.contentView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}




