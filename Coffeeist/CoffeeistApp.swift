//
//  CoffeeistApp.swift
//  Coffeeist
//
//  Created by Juan Colmenares on 5/3/25.
//

import SwiftUI

@main
struct CoffeeistApp: App {
    @StateObject private var dataManager = PreparationDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
