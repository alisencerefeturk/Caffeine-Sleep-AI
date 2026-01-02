//
//  Health_Coach_AppApp.swift
//  Health Coach App
//
//  Created by Ali Sencer Efetürk on 11.12.2025.
//

import SwiftUI

@main
struct Health_Coach_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
