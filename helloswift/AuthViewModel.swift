//
//  AuthViewModel.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

//import Foundation
import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var uid: String? = nil
    @Published var email: String? = nil
    @Published var displayName: String? = nil
    
    //    @Published var errMessage: String? = nil
    
    init() {
        observeAuthChanges()
    }
    
    private func observeAuthChanges () {
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            //            DispatchQueue.main.async {
            self?.isAuthenticated = user != nil
            self?.uid = user?.uid
            self?.email = user?.email
            self?.displayName = user?.displayName
            //            }
        }
    }
    
    func signIn(email: String, password: String) async throws -> String {
        //        do {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid
        return uid
        /*        } catch {
         if let error = error as NSError? {
         if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
         switch errorCode {
         case .invalidEmail:
         self.errMessage = "メールアドレスの形式が違います"
         case .emailAlreadyInUse:
         self.errMessage = "このメールアドレスは既に使われています"
         case .userNotFound, .wrongPassword:
         self.errMessage = "メールアドレス、またはパスワードが間違っています"
         default:
         print("予期せぬエラーが発生しました")
         }
         }
         }
         return self.errMessage ?? ""
         } */
    }
    
    func signUp(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            /*            { [weak self] result, error in
             if result != nil, error == nil {
             DispatchQueue.main.async {
             self?.isAuthenticated = true
             }
             } */
            let uid = result.user.uid
            
            // do updateDisplayName
            await self.updateDisplayName(displayName: uid)
            
            return uid
        }
    }
    
    func updateDisplayName(displayName: String) async {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        
        do {
            try await changeRequest?.commitChanges()
            //print("new displayName: \(displayName)")
            DispatchQueue.main.async {
                self.displayName = displayName
            }
        } catch {
            print("change displayName error: \(String(describing: error))")
        }
    }
    
    func updatePassword (currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
        
        do {
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        } catch {
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        } catch let signOutError as NSError {
            debugPrint("Error signing out: %@", signOutError)
        }
    }
    
    func deleteUser() {
        do {
            let user = Auth.auth().currentUser
            user?.delete { error in
                if let error = error {
                    // An error occurred when delete user
                } else {
                    // Account deleted successfully.
                    DispatchQueue.main.async {
                        self.isAuthenticated = false
                    }
                }
            }
        } catch let signOutError as NSError {
            debugPrint("Error signing out: %@", signOutError)
        }
    }
}
