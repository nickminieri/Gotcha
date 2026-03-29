//
//  GotchaApp.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI
import Combine

// MARK: - App State
class AppState: ObservableObject {
    @Published var isLoggedIn = false

    func login() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            isLoggedIn = true
        }
    }

    func logout() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            isLoggedIn = false
        }
    }
}

// MARK: - App Entry Point
@main
struct GotchaApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    MarketplaceView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    LoginView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .environmentObject(appState)
        }
    }
}
