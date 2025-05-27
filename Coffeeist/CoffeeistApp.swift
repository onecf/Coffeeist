//
//  CoffeeistApp.swift
//  Coffeeist
//
//  Created by Juan Colmenares on 5/3/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CoffeeistApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Use the new services
    @StateObject private var authService = AuthenticationService()
    @StateObject private var databaseService = DatabaseService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
                    .environmentObject(databaseService)
            } else {
                AuthenticationView()
                    .environmentObject(authService)
            }
        }
    }
}
