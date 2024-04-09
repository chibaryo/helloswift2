//
//  AuthObserver.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import FirebaseAuth
import Combine

class AuthObserver: ObservableObject {
    private var listener: AuthStateDidChangeListenerHandle!
    @Published var isSubscribed: Bool = false
    @Published var uid: String? = nil

    init() {
        self.listener = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.isSubscribed = true
            self?.uid = user?.uid
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(listener!)
        self.isSubscribed = true
    }
}
