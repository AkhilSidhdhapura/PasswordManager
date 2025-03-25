//
//  AddPasswordView.swift
//  PasswordManagerDemo
//
//  Created by Akhil Sidhdhapura on 25/03/25.
//

import SwiftUI

struct AddPasswordView: View {
    
    @Binding var passwords: [(UserLocalData, UserData)]
    @Binding var isPresent: Bool
    
    @State private var accountType = ""
    @State private var email = ""
    @State private var password = ""
    @State private var strength: PasswordStrength = .weak
    
    @State private var isAccountError: Bool = false
    @State private var isEmailError: Bool = false
    @State private var isPasswordError: Bool = false
    @State private var toastMsg: String = String()
    
    @State var isEdit: Bool = false
    @State var editData: (UserLocalData, UserData)?
    
    var body: some View {
        self.contentView
            .onAppear {
                if self.isEdit {
                    if let editData = self.editData?.0 {
                        self.accountType = editData.accountName ?? ""
                        self.email = editData.email ?? ""
                        self.password = editData.password ?? ""
                    }
                }
            }
    }
    
    var contentView: some View {
        ZStack{
            VStack{
                Spacer()
                VStack(spacing: 0) {
                    
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 46, height: 4)
                        .foregroundColor(Color.text)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 22) {
                        TextField("Account Name", text: $accountType)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(Color.white.cornerRadius(6))
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(self.isAccountError ? Color.red : Color.text, lineWidth: 0.6)
                            }
                        
                        TextField("Username/ Email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(Color.white.cornerRadius(6))
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(self.isEmailError ? Color.red : Color.text, lineWidth: 0.6)
                            }
                        
//                        SecureField("Password", text: $password)
//                            .textFieldStyle(PlainTextFieldStyle())
//                            .padding(.horizontal)
//                            .frame(height: 44)
//                            .background(Color.white.cornerRadius(6))
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 6)
//                                    .stroke(self.isPasswordError ? Color.red : Color.text, lineWidth: 0.6)
//                            }
                        
                        VStack {
                            TextField("Enter Password", text: $password)
//                            SecureField("Enter Password", text: $password)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal)
                                .frame(height: 44)
                                .background(Color.white.cornerRadius(6))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(self.isPasswordError ? Color.red : Color.text, lineWidth: 0.6)
                                }
                                .onChange(of: password, perform: { newPassword in
                                    strength = checkPasswordStrength(newPassword)
                                })
                            
                            if !self.password.isEmpty {
                                HStack {
                                    ForEach(0..<4) { index in
                                        Rectangle()
                                            .fill(strength.color)
                                            .frame(width: 50, height: 6)
                                            .opacity(index < strength.level ? 1 : 0.3)
                                            .cornerRadius(3)
                                    }
                                    Spacer()
                                }
                                .animation(.easeInOut, value: strength.level)
                            }
                        }
                        
                    }
                    .padding(.vertical, 33)
                    
                    Button(action: {
                        if self.isValidate(accountNumber: self.accountType, email: self.email, password: self.password) {
                            if self.isEdit {
                                if let editData = self.editData {
                                    CoreDataManager.shared.deleteUser(user: editData.1)
                                    CoreDataManager.shared.saveUser(accountName: accountType, email: email, password: password)
                                    self.passwords = CoreDataManager.shared.fetchUsers()
                                }
                            } else {
                                CoreDataManager.shared.saveUser(accountName: accountType, email: email, password: password)
                                self.passwords = CoreDataManager.shared.fetchUsers()
                            }
                            self.isPresent = false
                        }
                    }) {
                        Text(self.isEdit ? "Edit Account" : "Add New Account")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(22)
                    }
                    .safeAreaPadding(.bottom)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
                .background(Color.bg)
                .clipShape(RoundedCorner(radius: 17, corners: [.topLeft, .topRight]))
            }
        }
        .zIndex(99)
        .toast(isShowing: $isAccountError, message: self.toastMsg)
        .toast(isShowing: $isEmailError, message: self.toastMsg)
        .toast(isShowing: $isPasswordError, message: self.toastMsg)
        
    }
    
    func isValidate(accountNumber: String?, email: String?, password: String?) -> Bool {
        
        self.isAccountError = false
        self.isEmailError = false
        self.isPasswordError = false
        
        guard let accountNumber = accountNumber, !accountNumber.isEmpty else {
            self.isAccountError = true
            self.toastMsg = "Please enter account number."
            return false
        }
        
        guard let email = email, !email.isEmpty else {
            self.isEmailError = true
            self.toastMsg = "Please enter email."
            return false
        }
        if !isValidEmail(email) {
            self.isEmailError = true
            self.toastMsg = "Please enter a valid email address."
            return false
        }
        
        guard let password = password, !password.isEmpty else {
            self.isPasswordError = true
            self.toastMsg = "Please enter password."
            return false
        }
        if password.count < 4 {
            self.isPasswordError = true
            self.toastMsg = "Password must be at least 4 characters long."
            return false
        }
        return true
    }
}

// MARK: - Password Strength Enum
enum PasswordStrength {
    case weak, moderate, strong, veryStrong
    
    var level: Int {
        switch self {
        case .weak: return 1
        case .moderate: return 2
        case .strong: return 3
        case .veryStrong: return 4
        }
    }
    
    var description: String {
        switch self {
        case .weak: return "Weak"
        case .moderate: return "Moderate"
        case .strong: return "Strong"
        case .veryStrong: return "Very Strong"
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .moderate: return .orange
        case .strong: return .yellow
        case .veryStrong: return .green
        }
    }
}

// MARK: - Password Strength Check Logic
func checkPasswordStrength(_ password: String) -> PasswordStrength {
    let length = password.count
    let containsUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
    let containsLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
    let containsNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
    let containsSpecial = password.rangeOfCharacter(from: .punctuationCharacters) != nil ||
                          password.rangeOfCharacter(from: .symbols) != nil

    var score = 0
    if length >= 8 { score += 1 }
    if containsUppercase && containsLowercase { score += 1 }
    if containsNumber { score += 1 }
    if containsSpecial { score += 1 }
    
    switch score {
    case 0...1: return .weak
    case 2: return .moderate
    case 3: return .strong
    default: return .veryStrong
    }
}
