import Foundation
import Capacitor
import StoreKit

/// One-off "CAS OBD Scanner Pro" purchase through StoreKit 2.
/// JavaScript calls: CAP.Plugins.CASPurchase.status() / purchase() / restore()
@objc(CASPurchasePlugin)
public class CASPurchasePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CASPurchasePlugin"
    public let jsName = "CASPurchase"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "status", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "purchase", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "restore", returnType: CAPPluginReturnPromise)
    ]

    static let proProductId = "uk.co.cassolutions.obdscanner.pro"
    private var updates: Task<Void, Never>?

    public override func load() {
        // Finish any purchase that completes outside the app (e.g. Ask to Buy approved later)
        updates = Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
            }
        }
    }

    deinit {
        updates?.cancel()
    }

    private func ownsPro() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == CASPurchasePlugin.proProductId,
               transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }

    private func priceText() async -> String {
        let products = try? await Product.products(for: [CASPurchasePlugin.proProductId])
        return products?.first?.displayPrice ?? ""
    }

    @objc func status(_ call: CAPPluginCall) {
        Task {
            let pro = await self.ownsPro()
            let price = await self.priceText()
            call.resolve(["pro": pro, "price": price])
        }
    }

    @objc func purchase(_ call: CAPPluginCall) {
        Task {
            do {
                guard let product = try await Product.products(for: [CASPurchasePlugin.proProductId]).first else {
                    call.resolve(["pro": false, "message": "The Pro version isn't available to buy right now. Please try again later."])
                    return
                }
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    if case .verified(let transaction) = verification {
                        await transaction.finish()
                        call.resolve(["pro": true])
                    } else {
                        call.resolve(["pro": false, "message": "Apple couldn't verify this purchase. Please try again."])
                    }
                case .userCancelled:
                    call.resolve(["pro": false, "message": "Purchase cancelled."])
                case .pending:
                    call.resolve(["pro": false, "message": "The purchase is waiting for approval."])
                @unknown default:
                    call.resolve(["pro": false, "message": "The purchase wasn't completed."])
                }
            } catch {
                call.reject("Purchase failed: \(error.localizedDescription)")
            }
        }
    }

    @objc func restore(_ call: CAPPluginCall) {
        Task {
            do {
                try await AppStore.sync()
                let pro = await self.ownsPro()
                call.resolve(["pro": pro])
            } catch {
                call.reject("Restore failed: \(error.localizedDescription)")
            }
        }
    }
}
