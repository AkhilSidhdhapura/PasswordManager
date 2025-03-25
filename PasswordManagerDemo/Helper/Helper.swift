//
//  Helper.swift
//  PasswordManagerDemo
//
//  Created by Akhil Sidhdhapura on 25/03/25.
//


import SwiftUI

var topSafeArea: CGFloat {
    let keyWindow = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
    
    return keyWindow?.safeAreaInsets.top ?? 0
}

// Email Validation Function
func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}


struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 50)
    }
}

// Custom Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                VStack {
                    ToastView(message: message)
                        .padding(topSafeArea)
                    Spacer()
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: isShowing)
            }
        }
        .onChange(of: self.isShowing, perform: { newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isShowing = false
            }
        })
        
        .zIndex(100)
    }
}

// Extension for easy use
extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}
