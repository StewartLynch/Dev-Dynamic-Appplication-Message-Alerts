//
// Created for AppAlertExample
// by  Stewart Lynch on 2023-11-16
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import Foundation
import SwiftUI

@Observable
class AlertService {
    struct Message: Codable {
        struct Link: Codable {
            let title: String
            let url: String
        }
        var id: Int = 0
        var bundleId: String = ""
        var title: String = ""
        var text: String = ""
        var confirmLabel: String = ""
        var appVersions: [String]?
        var osVersions: [String]?
        var link: Link?
    }
    
    let jsonURL: String
    let bundleIdentifier = Bundle.main.bundleIdentifier!
    var message = Message()
    var showMessage = false
    static let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let osVersion = UIDevice.current.systemVersion
    static let cacheLocation = URL.cachesDirectory
    static let userDefaultsLocation = URL.libraryDirectory.appending(path: "Preferences")
    
    var lastMessageId: Int {
        get {
            UserDefaults.standard.integer(forKey: "lastMessageId")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "lastMessageId")
        }
    }
    
    init(_ jsonURL: String) {
        self.jsonURL = jsonURL
    }
    
    func fetchMessage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: jsonURL)!)
            print(String(decoding: data, as: UTF8.self))
            if let message = try JSONDecoder().decode(
                [Message].self,
                from: data
            ).first(where: {
                $0.bundleId == bundleIdentifier
            }) {
                self.message = message
            }
        } catch {
            print("Could not decode")
        }
    }
    
    func showAlertIfNecessary() async {
        await fetchMessage()
        guard message.id > lastMessageId else { return }
        // Message has not been seen
        if let osVersions = message.osVersions {
            // Found an array of osVersions so check if current version is one of them
            guard osVersions.contains(Self.osVersion) else { return }
        }
        if let appVersions = message.appVersions {
            // Found an array of appVersions so check if thiw version is one of them
            guard appVersions.contains(Self.appVersion) else { return }
        }

        // All 3 guard checks have passed so show an alert
        showMessage.toggle()
        lastMessageId = message.id
    }
    
    struct AlertModifier: ViewModifier {
        @Bindable var alertService: AlertService
        func body(content: Content) -> some View {
            content
                .alert(alertService.message.title, 
                       isPresented: $alertService.showMessage) {
                    Button(alertService.message.confirmLabel) {}
                    if let link = alertService.message.link {
                        Link(link.title, destination: URL(string: link.url)!)
                    }
                } message: {
                    Text(alertService.message.text)
                }
        }
    }
}

extension View {
    func messageAlert(_ alertService: AlertService) -> some View {
        modifier(AlertService.AlertModifier(alertService: alertService))
    }
}
