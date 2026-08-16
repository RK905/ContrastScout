import Foundation
import StoreKit
import Observation

@MainActor
@Observable
final class UnlockStore {
    static let productID = "com.geeksdobyte.ContrastScout.unlock"

    var product: Product?
    var isUnlocked = false
    var isLoading = false
    var errorMessage: String?
    var priceText: String = "$4.99"

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
            if let product {
                priceText = product.displayPrice
            }
            await refreshEntitlements()
        } catch {
            errorMessage = "Could not load Scout Unlock. You can still compare colors."
        }
    }

    func purchase() async {
        guard let product else {
            errorMessage = "Scout Unlock is not available yet. Try again in a moment."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isUnlocked = true
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase could not be completed. Try Restore Purchases if you already bought Scout Unlock."
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !isUnlocked {
                errorMessage = "No previous Scout Unlock purchase was found for this Apple ID."
            }
        } catch {
            errorMessage = "Could not restore purchases. Check your Apple ID and try again."
        }
    }

    func canSave(currentCount: Int) -> Bool {
        isUnlocked || currentCount < PaletteLimits.freeSwatchCap
    }

    private func refreshEntitlements() async {
        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(entitlement),
               transaction.productID == Self.productID {
                isUnlocked = true
                return
            }
        }
        isUnlocked = false
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw UnlockError.unverified
        case .verified(let value):
            return value
        }
    }
}

enum UnlockError: Error {
    case unverified
}
