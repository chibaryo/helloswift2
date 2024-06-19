//
//  FileColorSchemePickerView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/09.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct ProfileEditView: View {
    @State private var isPopupShowing: Bool = false
    @ObservedObject var viewModel: AuthViewModel
    var oldPassword: String
    @State private var user: UserModel
    //var user: UserModel
//    @State private var user: UserModel

    @State var isLoading: Bool = false

    // Explicit initializer
    init(viewModel: AuthViewModel, oldPassword: String, user: UserModel) {
        self.viewModel = viewModel
        self.oldPassword = oldPassword
        self._user = State(initialValue: user)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("氏名")
                        Spacer()
                        Text("\(String(describing: viewModel.displayName ?? "氏名未設定"))")
                        Spacer()
                        Button("変更") {
                            alertTF(
                                title: "氏名を変更",
                                message: "現在の氏名: \(String(describing: viewModel.displayName ?? "氏名未設定"))",
                                hintText: "氏名を入力...",
                                primaryTitle: "保存",
                                secondaryTitle: "キャンセル"
                            ) { text in
                                print("text: \(text)")
                                Task {
                                    await viewModel.updateDisplayName(displayName: text)
                                    DispatchQueue.main.async {
                                        viewModel.displayName = text
                                    }
                                    // Update Firestore "users" name field.
                                    let db = Firestore.firestore()
                                    let userRef = db.collection("users").document(viewModel.uid!)
                                    try await userRef.updateData([
                                        "name": text
                                    ])

                                }
                                
                            } secondaryAction: {
                                print("Cancelled")
                            }
                        }
                    }
                    HStack {
                        Text("パスワード")
                        Spacer()
                        Text("********")
                            .frame(alignment: .leading)
                        Spacer()
                        Button("変更") {
                            alertTF(
                                title: "パスワードを変更",
                                message: "パスワード設定",
                                hintText: "パスワードを入力...",
                                primaryTitle: "保存",
                                secondaryTitle: "キャンセル"
                            ) { text in
                                print("text: \(text)")
                                Task {
                                    do {
                                        try await viewModel.updatePassword(currentPassword: self.oldPassword, newPassword: text)
                                        // Update Firestore password
                                        let db = Firestore.firestore()
                                        let userRef = db.collection("users").document(viewModel.uid!)
                                        try await userRef.updateData([
                                            "password": text
                                        ])
//                                        try UserViewModel.updateUser(uid: viewModel.uid, document: userDoc)
                                    } catch {
                                        print("Error updating document: \(error)")
                                    }
                                }

                            } secondaryAction: {
                                print("Cancelled")
                            }
                        }
                    }
                    HStack {
                        Text("部署")
                        Spacer()
                        Text(user.department)
                            .frame(alignment: .leading)
                        Spacer()
                        Button("変更") {
                            alertTF(
                                title: "部署を変更",
                                message: "現在の部署: " + user.department,
                                hintText: "部署を入力...",
                                primaryTitle: "保存",
                                secondaryTitle: "キャンセル"
                            ) { text in
                                print("text: \(text)")
                                Task {
                                    do {
                                        let db = Firestore.firestore()
                                        let userRef = db.collection("users").document(viewModel.uid!)
                                        try await userRef.updateData([
                                            "department": text
                                        ])
                                    } catch {
                                        print("Error updating document: \(error)")
                                    }
                                }

                            } secondaryAction: {
                                print("Cancelled")
                            }
                        }
                    }
                    HStack {
                        Text("支店")
                        Spacer()
                        Text(user.officeLocation)
                            .frame(alignment: .leading)
                        Spacer()
                        Button("変更") {
                            alertTF(
                                title: "支店を変更",
                                message: "現在の支店: " + user.officeLocation,
                                hintText: "支店を入力...",
                                primaryTitle: "保存",
                                secondaryTitle: "キャンセル"
                            ) { text in
                                print("text: \(text)")
                                Task {
                                    do {
                                        let db = Firestore.firestore()
                                        let userRef = db.collection("users").document(viewModel.uid!)
                                        try await userRef.updateData([
                                            "officeLocation": text
                                        ])
                                    } catch {
                                        print("Error updating document: \(error)")
                                    }
                                }

                            } secondaryAction: {
                                print("Cancelled")
                            }
                        }
                    }
                    HStack {
                        Text("役職")
                        Spacer()
                        Text(user.jobLevel)
                            .frame(alignment: .leading)
                        Spacer()
                        Button("変更") {
                            alertTF(
                                title: "役職を変更",
                                message: "現在の役職: " + user.jobLevel,
                                hintText: "役職を入力...",
                                primaryTitle: "保存",
                                secondaryTitle: "キャンセル"
                            ) { text in
                                print("text: \(text)")
                                Task {
                                    do {
                                        let db = Firestore.firestore()
                                        let userRef = db.collection("users").document(viewModel.uid!)
                                        try await userRef.updateData([
                                            "jobLevel": text
                                        ])
                                    } catch {
                                        print("Error updating document: \(error)")
                                    }
                                }

                            } secondaryAction: {
                                print("Cancelled")
                            }
                        }
                    }
                }
            }
        }
        VStack {
            Text("uid: \(String(describing: viewModel.uid!))")
        }
        .onAppear(perform: {
            fetchUserInfo()
        })
    }
    private func fetchUserInfo () {
        Task {
            do {
                isLoading.toggle()
                _ = try await UserViewModel.fetchUserByUid(documentId: viewModel.uid!)!
/*                notifications = try await NotificationViewModel.fetchNotifications()
                notiTemplates = try await NotiTemplateViewModel.fetchNotiTemplates() */
                isLoading.toggle()
                print("user: \(self._user)")

            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

//
extension View {
    // MARK: ALert TF
    func alertTF(
        title: String,
        message: String,
        hintText: String,
        primaryTitle: String,
        secondaryTitle: String,
        primaryAction: @escaping (String)->(),
        secondaryAction: @escaping ()->()
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.placeholder = hintText
        }
        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                secondaryAction()
            }
        }))
        alert.addAction(.init(title: primaryTitle, style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                DispatchQueue.main.async {
                    primaryAction(text)
                }
            } else {
                DispatchQueue.main.async {
                    primaryAction("")
                }
            }
        }))
        
        // MARK: Presenting Alert
        rootController().present(alert, animated: true, completion: nil)
    }
    
    // MARK: Root View Controller
    func rootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
