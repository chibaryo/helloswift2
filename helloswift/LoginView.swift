//
//  LoginScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State var inputEmail = ""
    @State var inputPassword = ""

    @State var isLoading: Bool = false
    @State var isActive: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField(text: $inputEmail, prompt: Text("メールアドレス")) {
                        Text("メールアドレス")
                    }
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    SecureField(text: $inputPassword, prompt: Text("パスワード")) {
                        Text("パスワード")
                    }
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button(action: {
                        print("Pressed! login")
                        viewModel.signIn(email: inputEmail, password: inputPassword)
                        //if (viewModel.isAuthenticated) {
                        //    HomeView(viewModel: viewModel)
                        //}
                    }, label: {
                        Text("ログイン")
                            .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
            }
        }
    }
}
