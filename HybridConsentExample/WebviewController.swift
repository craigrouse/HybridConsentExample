// 
// WebviewController.swift
// HybridConsentExample
//
//  Copyright © 2021 Tealium, Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import WebKit

struct WebViewControllerWrapper: View, UIViewControllerRepresentable {
    typealias UIViewControllerType = WebViewController
    var consentCategories: String
    
    func makeUIViewController(context: Context) -> WebViewController {
        let controller = WebViewController()
        controller.categories = consentCategories
        return controller
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        
    }
}

struct ViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




class WebViewController: UIViewController {
    
    var webView: WKWebView!
    var categories: String!
    
    override func loadView() {
        let config = WKWebViewConfiguration()
        // register a listener for "tealium" events
        config.userContentController.add(self, name: "tealium")
        webView = WKWebView(frame: CGRect(), configuration: config)
        // Load the webview URL, passing the consent categories in the query string
        webView.load(URLRequest(url: URL(string: "https://tags.tiqcdn.com/utag/tealiummobile/consent-manager-demo/prod/mobile.html?consent_categories=\(categories!)")!))
        view = webView
    }
    
    override func viewDidLoad() {
        
    }
    
}

// Handles consent syncing from the webview
extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                              didReceive message: WKScriptMessage) {

      guard let body = message.body as? [String: Any],
          let command = body["command"] as? String,
          let categories = body["categories"] as? String else {
              return
      }

        guard categories != "" else {
            TealiumHelper.setConsentStatus(status: "Not Consented")
            return
        }
        
        let categoriesArray = categories.components(separatedBy: ",")
        
        guard categoriesArray.count > 0 else {
            return
        }
        
      switch command {
      case "syncConsent":
        TealiumHelper.setConsentCategories(categoriesArray)
      default:
          break
      }
    }
}
