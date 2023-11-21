//
// Created for AppAlertExample
// by  Stewart Lynch on 2023-11-16
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI

struct ContentView: View {
    @State private var alertService = AlertService("https://stewartlynch.github.io/AppAlerts/messages.json")
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .messageAlert(alertService)
        }
        .padding()
        .task {
            await alertService.showAlertIfNecessary()
        }
    }
}

#Preview {
    ContentView()
}
