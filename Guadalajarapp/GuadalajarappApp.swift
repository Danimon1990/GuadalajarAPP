//
//  GuadalajarappApp.swift
//  Guadalajarapp
//
//  Created by Daniel Moreno on 10/11/24.
//

import SwiftUI
import FirebaseCore // 1. Add this import for Firebase

// 2. Define the AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure() // 3. Configure Firebase
    print("Firebase configured successfully!") // Optional: for debugging
    return true
  }
}

@main
struct GuadalajarappApp: App {
    // 4. Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AuthenticationWrapperView()
        }
    }
}
