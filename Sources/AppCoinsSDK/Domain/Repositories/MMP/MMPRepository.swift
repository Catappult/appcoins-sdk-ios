//
//  AttributionRepository.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class MMPRepository: MMPRepositoryProtocol {

    private let MMPService: MMPService = MMPClient()
    private var heartbeatActive = false

    internal func getAttribution() {
        // Skip if attribution already completed successfully (mirrors Android's ATTRIBUTION_COMPLETE_KEY).
        guard !isAttributionComplete() else { return }

        // Generate a local ID immediately if none exists, so it is available as a
        // fallback before the network response arrives. If a local ID already exists
        // (from a previous launch where attribution didn't complete), reuse it.
        // The guest_wallet endpoint requires exactly 40 word characters (^\w{40}$).
        let guestUID = UserDefaults.standard.string(forKey: "attribution-guestuid") ?? {
            let id = Self.generateGuestUID()
            UserDefaults.standard.set(id, forKey: "attribution-guestuid")
            return id
        }()

        self.MMPService.getAttribution(bundleID: Bundle.main.bundleIdentifier ?? "", guestUID: guestUID) { result in
            switch result {
            case .success(let attributionRaw):
                // Replace the local ID with the server-assigned one and mark complete.
                UserDefaults.standard.set(String(attributionRaw.guestUID), forKey: "attribution-guestuid")
                UserDefaults.standard.set(true, forKey: "attribution-complete")

                if let rawOemID = attributionRaw.oemID, rawOemID != "" {
                    UserDefaults.standard.set(rawOemID, forKey: "attribution-oemid")
                }

                if let v = attributionRaw.utmSource { UserDefaults.standard.set(v, forKey: "mmp-utm-source") }
                if let v = attributionRaw.utmMedium { UserDefaults.standard.set(v, forKey: "mmp-utm-medium") }
                if let v = attributionRaw.utmCampaign { UserDefaults.standard.set(v, forKey: "mmp-utm-campaign") }
                if let v = attributionRaw.utmContent { UserDefaults.standard.set(v, forKey: "mmp-utm-content") }
                if let v = attributionRaw.utmTerm { UserDefaults.standard.set(v, forKey: "mmp-utm-term") }

            case .failure: break
            }
        }
    }

    internal func getGuestUID() -> String? {
        return UserDefaults.standard.string(forKey: "attribution-guestuid")
    }

    internal func isAttributionComplete() -> Bool {
        return UserDefaults.standard.bool(forKey: "attribution-complete")
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
        let prevSessionStart = UserDefaults.standard.double(forKey: "mmp-session-start")
        if let prevSessionID = UserDefaults.standard.string(forKey: "mmp-session-id"),
           let guestUID = getGuestUID(), !guestUID.isEmpty,
           prevSessionStart > 0 {
            let prevSessionEnd = UserDefaults.standard.double(forKey: "mmp-session-end")
            let sessionEndWasRecorded = UserDefaults.standard.object(forKey: "mmp-session-end") != nil
            let endTime = sessionEndWasRecorded ? max(prevSessionEnd, prevSessionStart) : prevSessionStart
            let durationMs = max(0, Int((endTime - prevSessionStart) * 1000))
            let bundleID = Bundle.main.bundleIdentifier ?? ""
            let vercode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

            MMPService.sendUserSession(
                bundleID: bundleID,
                oemID: getOEMID() ?? "",
                guestUID: guestUID,
                sessionID: prevSessionID,
                sessionTimestamp: Int(prevSessionStart),
                sessionDuration: durationMs,
                vercode: vercode,
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
        let now = Date().timeIntervalSince1970
        UserDefaults.standard.set(UUID().uuidString, forKey: "mmp-session-id")
        UserDefaults.standard.set(now, forKey: "mmp-session-start")
        UserDefaults.standard.set(now, forKey: "mmp-session-end")
        startSessionHeartbeat()
    }

    private func startSessionHeartbeat() {
        heartbeatActive = true
        scheduleHeartbeat()
    }

    private func scheduleHeartbeat() {
        guard heartbeatActive else { return }
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.heartbeatActive else { return }
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "mmp-session-end")
            self.scheduleHeartbeat()
        }
    }

    // MARK: - Purchase

    internal func sendPurchaseEvent(sku: String, orderID: String, purchaseAmount: String, paymentMethod: String) {
        guard let guestUID = getGuestUID(), !guestUID.isEmpty else {
            Utils.log("Purchase MMP event skipped: guest_uid not available.", category: "MMP")
            return
        }
        let event = MMPPendingPurchaseEvent(
            packageName: Bundle.main.bundleIdentifier ?? "",
            oemID: getOEMID() ?? "",
            guestUID: guestUID,
            sku: sku,
            orderID: orderID,
            purchaseAmount: purchaseAmount,
            paymentMethod: paymentMethod,
            timestamp: Int(Date().timeIntervalSince1970),
            vercode: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
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
            timestamp: event.timestamp,
            vercode: event.vercode,
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

    // Generates a random 40-character hex string matching the ^\w{40}$ pattern
    // required by the guest_wallet endpoint, consistent with server-assigned guest UIDs.
    private static func generateGuestUID() -> String {
        let hex = "0123456789abcdef"
        return String((0..<40).compactMap { _ in hex.randomElement() })
    }
}
