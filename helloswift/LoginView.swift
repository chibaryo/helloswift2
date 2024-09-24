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
    @State private var errMessage: String? = nil

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
                    if self.errMessage != nil {
                        Text(self.errMessage!).foregroundColor(.red)
                    }
                    Button(action: {
                        print("Pressed! login")
                        Task {
                            do {
                                let result = try await viewModel.signIn(email: inputEmail, password: inputPassword)
                                print(result)
//                                if ((viewModel.errMessage) != nil) {
  //                                  print("viewModel.errMessage: \(String(describing: viewModel.errMessage))")
    //                            }
                            } catch {
                                if let error = error as NSError? {
                                    if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                                        DispatchQueue.main.async {
                                            switch errorCode {
                                                case .invalidEmail:
                                                    self.errMessage = "メールアドレスの形式が無効です"
                                                case .userNotFound, .wrongPassword:
                                                    self.errMessage = "メールアドレス、もしくはパスワードが間違っています"
                                                default:
                                                    self.errMessage = "ログインエラーです。メールアドレス、パスワードを確認してください。"
                                                    print("予期せぬエラーが発生しました")
                                            }
                                            print(errorCode)
                                        }
                                    }
                                }
                            }
                        }
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
