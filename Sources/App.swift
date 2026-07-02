import SwiftUI
import AppFactoryKit

// Room Styler — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "roomstyler_pro_yearly"
    static let weekly = "roomstyler_pro_weekly"
}

@MainActor
enum RoomStylerFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Room Styler",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "sofa.fill",
                          title: "Restyle Your Room",
                          message: "Snap your space and preview it in a new design mood — instantly, on-device."),
                    .init(systemImage: "paintpalette.fill",
                          title: "Find Your Style",
                          message: "Scandinavian, Cozy, Industrial, Luxe — see what fits before you decorate.")
                ],
                presentsPaywallOnFinish: true,
                accent: .purple
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Room Styler Pro",
                subheadline: "Every style, every room.",
                benefits: [
                    .init(systemImage: "paintpalette.fill", title: "All design styles"),
                    .init(systemImage: "square.and.arrow.down", title: "Save styled photos"),
                    .init(systemImage: "infinity", title: "Unlimited rooms"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/AIInteriorDesign/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/AIInteriorDesign/privacy.html"),
                style: PaywallStyle(accent: .purple, heroSystemImage: "sofa.fill")
            )
        )
        return AppFactory(config)
    }
}

@main
struct RoomStylerApp: App {
    @StateObject private var factory = RoomStylerFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.purple)
        }
    }
}
