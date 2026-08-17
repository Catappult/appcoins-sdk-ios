//
//  AttributionRepository.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class MMPRepository: MMPRepositoryProtocol {

    private let MMPService: MMPService = MMPClient()

    internal func getAttribution() {
        let guestUID = UserDefaults.standard.string(forKey: "attribution-guestuid")

        // Check if request has already been triggered
        if guestUID == nil {
            self.MMPService.getAttribution(bundleID: Bundle.main.bundleIdentifier ?? "") { result in
                switch result {
                case .success(let attributionRaw):
                    UserDefaults.standard.set(String(attributionRaw.guestUID), forKey: "attribution-guestuid")

                    if let rawOemID = attributionRaw.oemID, rawOemID != "" {
                        UserDefaults.standard.set(rawOemID, forKey: "attribution-oemid")
                    }

                    // Persist UTM fields from attribution for use in session and purchase events
                    if let v = attributionRaw.utmSource { UserDefaults.standard.set(v, forKey: "mmp-utm-source") }
                    if let v = attributionRaw.utmMedium { UserDefaults.standard.set(v, forKey: "mmp-utm-medium") }
                    if let v = attributionRaw.utmCampaign { UserDefaults.standard.set(v, forKey: "mmp-utm-campaign") }
                    if let v = attributionRaw.utmContent { UserDefaults.standard.set(v, forKey: "mmp-utm-content") }
                    if let v = attributionRaw.utmTerm { UserDefaults.standard.set(v, forKey: "mmp-utm-term") }

                case .failure: break
                }
            }
        }
    }

    internal func getGuestUID() -> String? {
        return UserDefaults.standard.string(forKey: "attribution-guestuid")
    }

    internal func getOEMID() -> String? {
        if let oemID = UserDefaults.standard.string(forKey: "attribution-oemid") { return oemID }
        else { return BuildConfiguration.aptoideOEMID }
    }

    // MARK: - Session

    internal func startSession() {
        // Replay any missed purchase events from previous sessions
        if FeatureFlags.mmpPurchaseResilience {
            replayPendingPurchaseEvents()
        }

        // Flush previous session data via user_session event
        if let prevSessionID = UserDefaults.standard.string(forKey: "mmp-session-id"),
           let prevSessionStart = UserDefaults.standard.object(forKey: "mmp-session-start") as? Double {
            let duration = max(0, Int(Date().timeIntervalSince1970 - prevSessionStart))
            let bundleID = Bundle.main.bundleIdentifier ?? ""
            let oemID = getOEMID() ?? ""
            let guestUID = getGuestUID() ?? ""

            MMPService.sendUserSession(
                bundleID: bundleID,
                oemID: oemID,
                guestUID: guestUID,
                sessionID: prevSessionID,
                sessionDuration: duration,
                utmSource: UserDefaults.standard.string(forKey: "mmp-utm-source"),
                utmMedium: UserDefaults.standard.string(forKey: "mmp-utm-medium"),
                utmCampaign: UserDefaults.standard.string(forKey: "mmp-utm-campaign"),
                utmContent: UserDefaults.standard.string(forKey: "mmp-utm-content"),
                utmTerm: UserDefaults.standard.string(forKey: "mmp-utm-term")
            ) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    Utils.log("User session event failed: \(error.localizedDescription)", category: "MMP", level: .error)
                }
            }
        }

        // Begin new session
        UserDefaults.standard.set(UUID().uuidString, forKey: "mmp-session-id")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "mmp-session-start")
    }

    // MARK: - Purchase

    internal func sendPurchaseEvent(sku: String, orderID: String, purchaseAmount: String, paymentMethod: String) {
        let event = MMPPendingPurchaseEvent(
            packageName: Bundle.main.bundleIdentifier ?? "",
            oemID: getOEMID() ?? "",
            guestUID: getGuestUID() ?? "",
            sku: sku,
            orderID: orderID,
            purchaseAmount: purchaseAmount,
            paymentMethod: paymentMethod,
            utmSource: UserDefaults.standard.string(forKey: "mmp-utm-source"),
            utmMedium: UserDefaults.standard.string(forKey: "mmp-utm-medium"),
            utmCampaign: UserDefaults.standard.string(forKey: "mmp-utm-campaign"),
            utmContent: UserDefaults.standard.string(forKey: "mmp-utm-content"),
            utmTerm: UserDefaults.standard.string(forKey: "mmp-utm-term")
        )
        dispatchPurchaseEvent(event)
    }

    // MARK: - Private helpers

    private func dispatchPurchaseEvent(_ event: MMPPendingPurchaseEvent) {
        MMPService.sendPurchaseEvent(
            bundleID: event.packageName,
            oemID: event.oemID,
            guestUID: event.guestUID,
            sku: event.sku,
            orderID: event.orderID,
            purchaseAmount: event.purchaseAmount,
            paymentMethod: event.paymentMethod,
            utmSource: event.utmSource,
            utmMedium: event.utmMedium,
            utmCampaign: event.utmCampaign,
            utmContent: event.utmContent,
            utmTerm: event.utmTerm
        ) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                Utils.log("Purchase MMP event failed (order: \(event.orderID)): \(error.localizedDescription)", category: "MMP", level: .error)
                if FeatureFlags.mmpPurchaseResilience {
                    self.storePendingPurchaseEvent(event)
                }
            }
        }
    }

    private func replayPendingPurchaseEvents() {
        guard let data = UserDefaults.standard.data(forKey: "mmp-pending-purchases"),
              let events = try? JSONDecoder().decode([MMPPendingPurchaseEvent].self, from: data),
              !events.isEmpty else { return }

        Utils.log("Replaying \(events.count) pending MMP purchase event(s).", category: "MMP")
        UserDefaults.standard.removeObject(forKey: "mmp-pending-purchases")

        for event in events {
            dispatchPurchaseEvent(event)
        }
    }

    private func storePendingPurchaseEvent(_ event: MMPPendingPurchaseEvent) {
        var events: [MMPPendingPurchaseEvent] = []
        if let data = UserDefaults.standard.data(forKey: "mmp-pending-purchases"),
           let existing = try? JSONDecoder().decode([MMPPendingPurchaseEvent].self, from: data) {
            events = existing
        }
        events.append(event)
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: "mmp-pending-purchases")
        }
    }
}
