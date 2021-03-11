// 
// ContentView.swift
// HybridConsentExample
//
//  Copyright © 2021 Tealium, Inc. All rights reserved.
//

import SwiftUI
import WebKit


struct ContentView: View {
    @State var presentingModal = false
    @State var consentValue: Double = 0
    @ObservedObject var updater = Updater()
    
    var consentStatus: String {
        switch Int(consentValue.rounded()) {
        case 0:
            return "Not Consented"
        case 1:
            return "Analytics"
        case 2:
            return "Performance"
        case 3:
            return "Full"
        case 4:
            return "Custom"
        default:
            return "Unknown"
        }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            Text("Your Consent Preferences").bold()
            
            Spacer()
            
            Text("We would like to track your activity to help us improve our services")
                .frame(width: 200, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            VStack {
                Button("I consent", action: {
                    self.consentValue = 3
                    self.consentChanged()
                }).padding().border(Color.green, width: 4)
                
                Spacer()
                
                Button("Decline consent", action: {
                    self.consentValue = 0
                    self.consentChanged()
                }).padding().border(Color.red, width: 4)
                
                Spacer()
                
                Text("Consent: \(consentStatus)")
                    .onReceive(updater.$consentChanged, perform: { _ in
                    self.consentValue = Double(TealiumHelper.getConsentStatus().1)
                })
                
                Slider(value: $consentValue,
                       in: 0...3,
                       step: 1.0,
                       onEditingChanged: { isChanging in
                        if !isChanging {
                            self.consentChanged()
                        }
                       })
                    .frame(width: 200, height: 100, alignment: .center)
                    .onReceive(updater.$consentExpired, perform: { _ in
                        self.consentValue = 0
                       })
                    .onReceive(updater.$consentReady, perform: { _ in
                        self.consentValue = Double(TealiumHelper.getConsentStatus().1)
                    })
                
                Button("Launch Webview", action: {
                    self.presentingModal = true
                }).sheet(isPresented: $presentingModal, content: {
                    ModalView(presentedAsModal: self.$presentingModal)
                }).padding().border(Color.black, width: 1)
                
                Spacer()
                
                Button("Track Event", action: {
                    TealiumHelper.trackEvent(title: "Consent Test", data: nil)
                }).padding().border(Color.black, width: 1)
                Spacer()
            }
        }
    }
    
    func consentChanged() {
        print("\(consentStatus)")
        updater.consentChanged = false
        TealiumHelper.setConsentStatus(status: consentStatus)
    }
}

// Publish consent events to update the UI
class Updater: ObservableObject {
    @Published var consentExpired: Bool = false
    @Published var consentChanged: Bool = false
    @Published var consentReady: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(forName: Notification.Name("com.tealium.consentexpired"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.consentExpired = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("com.tealium.consentchanged"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.consentChanged = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("com.tealium.consentready"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.consentReady = true
            }
        }
    }
}

struct ModalView: View {
    @Binding var presentedAsModal: Bool
    var body: some View {
        WebViewControllerWrapper(consentCategories: TealiumHelper.consentCategories)
        Button(action: {
            self.presentedAsModal = false
        }) {
            Text("Exit Webview").frame(height: 60)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
