//
//  CoreDataManager.swift
//  PasswordManagerDemo
//
//  Created by Akhil Sidhdhapura on 25/03/25.
//

import CryptoKit
import CoreData
import SwiftUI

//class CoreDataManager {
//    
//    static let shared = CoreDataManager()
//    let container: NSPersistentContainer
//    let context: NSManagedObjectContext
//
//    private init() {
//        container = NSPersistentContainer(name: "UserData")
//        container.loadPersistentStores { _, error in
//            if let error = error {
//                fatalError("Failed to load Core Data: \(error)")
//            }
//        }
//        context = container.viewContext
//    }
//
//    // MARK: - Save User
//    func saveUser(accountName: String, email: String, password: String) {
//        let user = UserData(context: context)
//        user.accountName = accountName
//        user.email = email
//        user.password = password
//
//        do {
//            try context.save()
//            print("User saved successfully!")
//        } catch {
//            print("Failed to save user: \(error)")
//        }
//    }
//
//    // MARK: - Fetch Users
//    func fetchUsers() -> [UserData] {
//        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
//        
//        do {
//            return try context.fetch(request)
//        } catch {
//            print("Failed to fetch users: \(error)")
//            return []
//        }
//    }
//
//    // MARK: - Delete User
//    func deleteUser(user: UserData) {
//        context.delete(user)
//        
//        do {
//            try context.save()
//            print("User deleted successfully!")
//        } catch {
//            print("Failed to delete user: \(error)")
//        }
//    }
//
//    // MARK: - Delete All Users
//    func deleteAllUsers() {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserData.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        
//        do {
//            try context.execute(deleteRequest)
//            try context.save()
//            print("All users deleted successfully!")
//        } catch {
//            print("Failed to delete all users: \(error)")
//        }
//    }
//}

class CoreDataManager {
    
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    private init() {
        container = NSPersistentContainer(name: "UserData")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error)")
            }
        }
        context = container.viewContext
    }

    // MARK: - Save User (Encrypted)
    func saveUser(accountName: String, email: String, password: String) {
        let user = UserData(context: context)
        user.accountName = accountName

        // Convert email & password to encrypted Data
        user.email = AESHelper.encrypt(email)
        user.password = AESHelper.encrypt(password)

        do {
            try context.save()
            print("User saved securely!")
        } catch {
            print("Failed to save user: \(error)")
        }
    }

    // MARK: - Fetch Users (Decrypted)
    func fetchUsers() -> [(UserLocalData, UserData)] {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        
        do {
            let users = try context.fetch(request)
            return users.map { user in
                var decryptedUser = user
                
                let obj = UserLocalData(accountName: user.accountName ?? "", email: AESHelper.decrypt(user.email ?? Data()), password: AESHelper.decrypt(user.password ?? Data()))
                
                decryptedUser.email = user.email
                decryptedUser.password = user.password
                return (obj, decryptedUser)
            }
        } catch {
            print("Failed to fetch users: \(error)")
            return []
        }
    }

    // MARK: - Delete User
    func deleteUser(user: UserData) {
        context.delete(user)
        
        do {
            try context.save()
            print("User deleted successfully!")
        } catch {
            print("Failed to delete user: \(error)")
        }
    }

    // MARK: - Delete All Users
    func deleteAllUsers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All users deleted successfully!")
        } catch {
            print("Failed to delete all users: \(error)")
        }
    }
}

class UserLocalData {
    
    var accountName: String?
    var email: String?
    var password: String?
    
    init(accountName: String? = nil, email: String? = nil, password: String? = nil) {
        self.accountName = accountName
        self.email = email
        self.password = password
    }
}

//struct AESHelper {
//    private static let key = SymmetricKey(size: .bits256) // 256-bit encryption key
//    
//    // Encrypt a string
//    static func encrypt(_ text: String) -> Data? {
//        guard let data = text.data(using: .utf8) else { return nil }
//        
//        do {
//            let sealedBox = try AES.GCM.seal(data, using: key)
//            return sealedBox.combined // Encrypted data
//        } catch {
//            print("Encryption error: \(error)")
//            return nil
//        }
//    }
//    
//    // Decrypt data
//    static func decrypt(_ encryptedData: Data) -> String? {
//        do {
//            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
//            let decryptedData = try AES.GCM.open(sealedBox, using: key)
//            return String(data: decryptedData, encoding: .utf8)
//        } catch {
//            print("Decryption error: \(error)")
//            return nil
//        }
//    }
//}

import Foundation
import CryptoKit
import Security

import Foundation
import CryptoKit
import Security

struct AESHelper {
    private static let keyTag = "com.PM.encryptionKey"

    // 🔹 Fetch or Generate AES Key
    private static var key: SymmetricKey {
        if let storedKeyData = KeychainHelper.loadKey(tag: keyTag) {
            return SymmetricKey(data: storedKeyData)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            KeychainHelper.saveKey(newKey.data, tag: keyTag)
            return newKey
        }
    }

    // 🔹 Encrypt a String
    static func encrypt(_ text: String) -> Data? {
        guard let data = text.data(using: .utf8) else { return nil }
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }

    // 🔹 Decrypt Data
    static func decrypt(_ encryptedData: Data) -> String? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
}

// 🔹 Convert SymmetricKey to Data
private extension SymmetricKey {
    var data: Data {
        withUnsafeBytes { Data($0) }
    }
}



struct KeychainHelper {
    // Save Key to Keychain
    static func saveKey(_ key: Data, tag: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary) // Remove existing key if any
        SecItemAdd(query as CFDictionary, nil)
    }

    // Load Key from Keychain
    static func loadKey(tag: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        return (status == errSecSuccess) ? (dataTypeRef as? Data) : nil
    }
}
