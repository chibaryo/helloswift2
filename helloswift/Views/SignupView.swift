//
//  LoginScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var inputDisplayName: String = ""
    @State private var inputEmail: String = ""
    @State private var inputPassword: String = ""

    @State var isLoading: Bool = false
    @State var isActive: Bool = false
    @State private var errMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField(text: $inputDisplayName, prompt: Text("名前")) {
                        Text("名前")
                    }
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                        .padding()
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
                        print("Pressed! signup")
                        Task {
                            do {
                                let uid = try await viewModel.signUp(email: inputEmail, password: inputPassword)
                                //let result = try await viewModel.signIn(email: inputEmail, password: inputPassword)
                                print(uid)
                                // if result ok, then register to firestore
                                let userDoc = UserModel(
                                    uid: uid,
                                    name: inputDisplayName,
                                    email: inputEmail,
                                    password: inputPassword,
                                    isAdmin: false
                                )
                                try await UserViewModel.addUser(uid, document: userDoc)
                                   
//                                try await Firestore().firestore.collection("users").addDocument(data: <#T##[String : Any]#>)
//                                if ((viewModel.errMessage) != nil) {
  //                                  print("viewModel.errMessage: \(String(describing: viewModel.errMessage))")
    //                            }
                            } catch {
                                if let error = error as NSError? {
                                    if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                                        switch errorCode {
                                            case .invalidEmail:
                                                self.errMessage = "メールアドレスの形式が無効です"
                                            case .userNotFound, .wrongPassword:
                                                self.errMessage = "メールアドレス、もしくはパスワードが間違っています"
                                            default:
                                                print("予期せぬエラーが発生しました")
                                        }
                                        print(errorCode)
                                    }
                                }
                            }
                        }
                        //if (viewModel.isAuthenticated) {
                        //    HomeView(viewModel: viewModel)
                        //}
                    }, label: {
                        Text("サインアップ")
                            .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
            }
        }
    }
}
