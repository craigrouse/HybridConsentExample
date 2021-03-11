//
// TealiumHelper.swift
// HybridConsentExample
//
//  Copyright © 2021 Tealium, Inc. All rights reserved.
//


import Foundation
import TealiumCore
import TealiumCollect
import TealiumTagManagement

enum TealiumConfiguration {
    static let account = "tealiummobile"
    static let profile = "demo"
    static let environment = "dev"
}

class TealiumHelper {
 
    static let consentOptions  = [
        "full" : TealiumConsentCategories.all,
        "performance": [TealiumConsentCategories.affiliates,TealiumConsentCategories.analytics,TealiumConsentCategories.bigData],
        "analytics": [TealiumConsentCategories.analytics]
    ]
    
    static let shared = TealiumHelper()
    
    static let config = TealiumConfig(account: TealiumConfiguration.account,
        profile: TealiumConfiguration.profile,
        environment: TealiumConfiguration.environment)

    static var tealium: Tealium?
    
    private init() {}
    
    public static func start() {
        config.logLevel = .info
        // Use this parameter to handle consent expiry
        config.onConsentExpiration = ({
            NotificationCenter.default.post(Notification(name: Notification.Name("com.tealium.consentexpired")))
            print("Consent expired: revalidation required")
        })
        // set consent policy to GDPR
        config.consentPolicy = .gdpr
        // Set consent to expire after a period of time
        config.consentExpiry = (1, .days)
//        config.consentExpiry = (1, .minutes)
//        config.consentExpiry = (1, .hours)
        config.collectors = [Collectors.AppData,
                             Collectors.Connectivity,
                             Collectors.Device]
        // For this demo, we're only using Collect, but you could also use TagManagement
        config.dispatchers = [Dispatchers.Collect]
        TealiumHelper.tealium = Tealium(config: config)
        DispatchQueue.main.async {
            NotificationCenter.default.post(Notification(name: Notification.Name("com.tealium.consentready")))
        }
        
    }
    
    class func trackView(title: String, data: [String: Any]?) {
        let tealiumView = TealiumView(title, dataLayer: data)
        TealiumHelper.tealium?.track(tealiumView)
    }

    class func trackEvent(title: String, data: [String: Any]?) {
        let tealiumEvent = TealiumEvent(title, dataLayer: data)
        TealiumHelper.tealium?.track(tealiumEvent)
    }

    // Handles consent status changes from the UI
    class func setConsentStatus(status: String) {
        switch status {
        case "Full":
            TealiumHelper.tealium?.consentManager?.userConsentStatus = .consented
        case "Performance":
            TealiumHelper.tealium?.consentManager?.userConsentCategories = [.affiliates,.analytics,.bigData]
        case "Analytics":
            TealiumHelper.tealium?.consentManager?.userConsentCategories = [.analytics]
        case "Not Consented":
            TealiumHelper.tealium?.consentManager?.userConsentStatus = .notConsented
        default:
            break
        }
    }
    
    class func getConsentStatus() -> (String, Int) {
        guard let _ = TealiumHelper.tealium?.consentManager?.userConsentStatus,
              let categories = TealiumHelper.tealium?.consentManager?.userConsentCategories else {
            return ("Not Consented", 0)
        }
         
        switch categories {
        case consentOptions["full"]!:
            return ("Full", 3)
        case consentOptions["analytics"]!:
            return ("Analytics", 1)
        case consentOptions["performance"]!:
            return ("Performance", 2)
        default:
            return ("Custom", 4)
        }
    }
    
    /// Called when webview consent status changes
    class func setConsentCategories(_ categories: [String]) {
        print("Webview: Setting consent categories to: \(categories)")
        NotificationCenter.default.post(Notification(name: Notification.Name("com.tealium.consentchanged")))
        TealiumHelper.tealium?.consentManager?.userConsentCategories = consentCategoriesStringToEnum(categories)
    }

}

// MARK: Consent Helpers
extension TealiumHelper {
    
    static var consentCategories: String {
        guard let categories = TealiumHelper.tealium?.consentManager?.userConsentCategories else {
            return ""
        }
        return consentCategoriesEnumToStringArray(categories).joined(separator: ",")
    }
    
    static func consentCategoriesEnumToStringArray(_ categories: [TealiumConsentCategories]) -> [String] {
        var converted = [String]()
        categories.forEach { category in
            converted.append(category.rawValue)
        }
        return converted
    }
    
    static func consentCategoriesStringToEnum(_ categories: [String]) -> [TealiumConsentCategories] {
        var converted = [TealiumConsentCategories]()
        categories.forEach { category in
            if let catEnum = TealiumConsentCategories(rawValue: category) {
                converted.append(catEnum)
            }
        }
        return converted
    }
}
