// 
// HybridConsentExampleApp.swift
// HybridConsentExample
//
//  Copyright © 2021 Tealium, Inc. All rights reserved.
//

import SwiftUI

@main
struct HybridConsentExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Init Tealium
        TealiumHelper.start()
        return true
    }
    
}
