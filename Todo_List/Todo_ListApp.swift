//
//  Todo_ListApp.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import SwiftUI
import FirebaseCore

@main
struct Todo_ListApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
