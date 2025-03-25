//
//  ContentView.swift
//  PasswordManagerDemo
//
//  Created by Akhil Sidhdhapura on 25/03/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var isPresentAddPasswordView: Bool = false
    @State private var isPresentPasswordDetailView: Bool = false
    @State private var isEdit: Bool = false
    
    @State private var arrPasswords: [(UserLocalData, UserData)] = []
    @State private var selectedUserData: (UserLocalData, UserData)?
    
    var body: some View {
        self.contentView
            .ignoresSafeArea()
            .onAppear {
                self.arrPasswords = CoreDataManager.shared.fetchUsers()
            }
    }
    
    var contentView: some View {
        ZStack {
            VStack(spacing: 0) {
                self.navigationView
                if self.arrPasswords.count > 0 {
                    self.passwordListView
                    Spacer()
                } else {
                    Spacer()
                    Text("No Passwords")
                        .bold()
                    Spacer()
                }
            }
            
            // Plus Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            self.isPresentAddPasswordView.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 26, height: 26)
                            .foregroundColor(Color.white)
                            .padding(16)
                            .background(
                                Color.btnBG
                                    .cornerRadius(10)
                            )
                    }
                }
                .padding(.trailing, 30)
            }
            .safeAreaPadding(.bottom)
            .padding(.bottom, 30)
            
            if self.isPresentAddPasswordView || self.isPresentPasswordDetailView {
                addTransparancyView()
                    .onTapGesture {
                        withAnimation {
                            self.isPresentAddPasswordView = false
                            self.isPresentPasswordDetailView = false
                        }
                    }
            }
            
            // Present Add Password View
            if self.isPresentAddPasswordView {
                ZStack{
                    VStack {
                        Spacer()
                        AddPasswordView(passwords: $arrPasswords, isPresent: self.$isPresentAddPasswordView, isEdit: self.isEdit, editData: self.selectedUserData)
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
            // Present Password Detail View
            if self.isPresentPasswordDetailView {
                ZStack{
                    VStack {
                        Spacer()
                        PasswordDetailView(userDatas: self.$arrPasswords, userData: self.selectedUserData ?? self.arrPasswords.first!, isPresent: self.$isPresentPasswordDetailView, complition: {
                            self.isPresentAddPasswordView = true
                            self.isEdit = true
                        })
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.bg
        )
    }
    
    var navigationView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack{
                Text("Password Manager")
                    .bold()
                    .padding(15)
                
                Spacer()
                
            }
            Divider()
        }
        .frame(height: 60)
        .padding(.top, topSafeArea)
    }
    
    var passwordListView: some View {
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                ForEach(0..<self.arrPasswords.count, id: \.self) { i in
                    commonCell(obj: self.arrPasswords[i].0)
                        .onTapGesture {
                            self.selectedUserData = self.arrPasswords[i]
                            withAnimation {
                                self.isPresentPasswordDetailView = true
                            }
                        }
                }
            }
            .padding(14)
            .padding(.vertical, 10)
        }
        
        func commonCell(obj: UserLocalData) -> some View {
            HStack {
                Text(obj.accountName ?? "")
                    .bold()
                Text("******")
                    .foregroundColor(Color.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 7, height: 13)
                    .scaledToFit()
            }
            .padding(EdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 20))
            .background(
                Color.white
                    .cornerRadius(33)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 33)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
    }
}

#Preview {
    HomeView()
}
