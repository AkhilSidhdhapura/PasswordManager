//
//  PasswordManagerDemoApp.swift
//  PasswordManagerDemo
//
//  Created by Akhil Sidhdhapura on 25/03/25.
//

import SwiftUI
import LocalAuthentication

@main
struct PasswordManagerDemoApp: App {
    
    @State var isAuthenticate: Bool = false
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            VStack {
//                if isAuthenticate {
                    HomeView()
                        .environment(\.managedObjectContext, persistenceController.context)
//                }
            }
//            .onAppear {
//                self.authenticateUser()
//            }
        }
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your account."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticate = true
                        // Authentication successful
                        print("Authentication successful")
                        // Proceed with accessing protected content
                    } else {
                        self.isAuthenticate = false
                        // Authentication failed
                        print("Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                        // Handle the failure (e.g., show an alert)
                    }
                }
            }
        } else {
            // Biometric authentication not available
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            // Handle the unavailability (e.g., fallback to password authentication)
        }
    }
}
