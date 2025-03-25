//
//  PasswordDetailView.swift
//  PasswordManagerDemo
//
//  Created by Akhil Sidhdhapura on 25/03/25.
//

import SwiftUI

struct PasswordDetailView: View {
    
    @Binding var userDatas: [(UserLocalData, UserData)]
    var userData: (UserLocalData, UserData)
    
    @State var isPasswordShow: Bool = false
    @State var isDeletePassword: Bool = false
    @Binding var isPresent: Bool
    
    var complition: ()-> Void
    
    var body: some View {
        self.contentView
            .alert("", isPresented: $isDeletePassword) {
                Button("Delete", role: .destructive) {
                    CoreDataManager.shared.deleteUser(user: self.userData.1)
                    self.userDatas = CoreDataManager.shared.fetchUsers()
                    self.isPresent = false
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete?")
            }
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 46, height: 4)
                .foregroundColor(Color.text)
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Account Details")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.btnBG)
                    .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Account Type")
                        .font(.caption)
                        .foregroundColor(Color.text)
                    
                    Text(userData.0.accountName ?? "")
                        .font(.headline)
                        .padding(.bottom)
                    
                    Text("Username/ Email")
                        .font(.caption)
                        .foregroundColor(Color.text)
                    Text(userData.0.email ?? "")
                        .font(.headline)
                        .padding(.bottom)
                    
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(Color.text)
                    
                    HStack {
                        Text(self.isPasswordShow ? self.userData.0.password ?? "********" : "********")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            self.isPasswordShow.toggle()
                        }) {
                            Image(systemName: self.isPasswordShow ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom)
                }
                
                HStack {
                    Button(action: {
                        self.complition()
                        self.isPresent = false
                    }) {
                        Text("Edit")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(22)
                    }
                    
                    Button(action: {
                        self.isDeletePassword = true
                    }) {
                        Text("Delete")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.red)
                            .cornerRadius(22)
                    }
                }
                .padding(.vertical)
            }
            .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
        }
        .background(Color.bg)
        .clipShape(RoundedCorner(radius: 17, corners: [.topLeft, .topRight]))
    }
}
