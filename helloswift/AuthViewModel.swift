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
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                if result != nil, error == nil {
                    DispatchQueue.main.async {
                        self?.isAuthenticated = true
                    }
                }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                if result != nil, error == nil {
                    DispatchQueue.main.async {
                        self?.isAuthenticated = true
                }
            }
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
}
