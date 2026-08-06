//
//  SDKModeInfoPopup.swift
//  AppCoinsSDK
//

import UIKit

internal struct SDKModeInfoPopup {

    @MainActor
    internal static func show(mode: SDKAvailabilityMode, detail: String? = nil) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "SDK Availability Mode: \(mode.displayName)"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        stack.addArrangedSubview(titleLabel)

        if let detail = detail {
            let detailLabel = UILabel()
            detailLabel.text = detail
            detailLabel.textColor = UIColor.white.withAlphaComponent(0.75)
            detailLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            stack.addArrangedSubview(detailLabel)
        }

        container.addSubview(stack)
        window.addSubview(container)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            container.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])

        container.alpha = 0
        UIView.animate(withDuration: 0.3) { container.alpha = 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3, animations: {
                container.alpha = 0
            }, completion: { _ in
                container.removeFromSuperview()
            })
        }
    }
}
