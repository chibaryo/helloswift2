//
//  AppHomeScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

//import Foundation
import SwiftUI

struct Country: Identifiable, Hashable {
    var tagname: String
    var desc: String
    var symbol: String
    var id: String { self.tagname }
}

struct SettingsScreen: View {
    var viewModel: AuthViewModel
    //    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled = false
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @AppStorage("pageSelection") var pageSelection: Int = 2

    //@State var isDarkModeEnabled: Bool = false
    @State var isPresented: Bool = false
    @State private var selectedLanguage: String = ""
    //
    @Binding var user: UserModel?
    @State var isLoading: Bool = false
    //
    @State private var isAdmin: Bool = false
    @State private var oldPassword: String = ""
    //
    @Binding var notifications: [NotificationModel]
    @Binding var answeredNotifications: [NotificationModel]
    @Binding var availableNotifications: [NotificationModel]
    @Binding var reportsByMe: [ReportModel]

    @State private var showingDelUserConfirmation = false

    let countries: [Country] = [
        Country(tagname: "japanese", desc: "日本語", symbol: "🇯🇵"),
        Country(tagname: "chinese", desc: "中国語", symbol: "🇨🇳"),
        Country(tagname: "korean", desc: "韓国語", symbol: "🇰🇷"),
        Country(tagname: "english", desc: "英語", symbol: "🇺🇸"),
    ]
/*
    init(
        viewModel: AuthViewModel,
        user: Binding<UserModel?>,
        notifications: Binding<[NotificationModel]>,
        answeredNotifications: Binding<[NotificationModel]>,
        availableNotifications: Binding<[NotificationModel]>,
        reportsByMe: Binding<[ReportModel]>
    ) {
        debugPrint("init setei")
        self.viewModel = viewModel
        self._user = user
        self._notifications = notifications
        self._answeredNotifications = answeredNotifications
        self._availableNotifications = availableNotifications
        self._reportsByMe = reportsByMe
    }
*/

    var body: some View {
        VStack {
            TopBar()
            NavigationStack {
                Form {
                    Group {
                        HStack {
                            //Spacer()
                                NavigationLink {
                                    ProfileEditView(
                                        viewModel: viewModel,
                                        oldPassword: self.oldPassword,
                                        user: user ?? UserModel(
                                            uid: "",
                                            name: "Unknown",
                                            email: "unknown@example.com",
                                            password: "",
                                            officeLocation: "",
                                            department: ["Unknown"],
                                            jobLevel: "",
                                            isAdmin: false
                                        )
                                    )
                                } label: {
                                    VStack {
                                        Image(systemName: "person")
                                            .resizable()
                                            .frame(width: 30, height: 30, alignment: .center)
                                        Text("\(String(describing: user?.name ?? "氏名未設定"))").font(.title)
                                        Text("Email: \(String(describing: viewModel.email!))").font(.subheadline).foregroundColor(.gray)
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Button(action: {}){
                                                Text("プロフィールを編集する")
                                                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                                                .font(.system(size: 18))
                                                .padding()
                                            }
                                            //.buttonStyle(.borderless)
                                            Spacer()
                                        }
                                    //                                        Text("プロフィールを編集する")
                                    //                                            .font(.system(size: 18))
                                    //                                            .padding()
                                }
                            }
                        }
                    }
                    
                    if ((user?.isAdmin) != false) {
                        Text(user?.name ?? "Unknown Name")
                        Section(header: Text("管理"), content: {
                            Section {
                                NavigationLink {
                                    NotiAdminScreen(
                                        viewModel: viewModel
                                    )
                                } label: {
                                    HStack {
                                        Text("通知管理")
                                    }
                                }
/*                                NavigationLink {
                                    ReportAdminScreen(
                                        viewModel: viewModel,
                                        slices: [
                                                    (1, .blue),
                                                    (2, .red),
                                                ]                                    )
                                } label: {
                                    HStack {
                                        Text("レポート管理")
                                    }
                                } */
                                if (user?.jobLevel == "管理者") {
                                    NavigationLink {
                                        TemplateAdminScreen(viewModel: viewModel)
                                    } label: {
                                        HStack {
                                            Text("テンプレート管理")
                                        }
                                    }
                                }
                                if ((user?.jobLevel) == "管理者") {
                                    NavigationLink {
                                        UserAdminScreen(viewModel: viewModel)
                                    } label: {
                                        HStack {
                                            Text("ユーザ管理")
                                        }
                                    }
                                }
                            }
                        })
                    }
                    Section(
                        header: Group {
                            if selectedLanguage == "japanese" {
                                Text("一般")
                            } else if selectedLanguage == "chinese" {
                                Text("通用")
                            } else if selectedLanguage == "korean" {
                                Text("일반")
                            } else if selectedLanguage == "english" {
                                Text("General")
                            }
                        },
                        content: {
                            Section {
                                Picker("カラーテーマ", selection: $appearanceMode) {
                                    Text("システム標準")
                                        .tag(0)
                                    Text("ダークモード")
                                        .tag(1)
                                    Text("ライトモード")
                                        .tag(2)
                                }
                                .pickerStyle(.automatic)
                            }
                            NavigationLink{
                                ToggleNotiGenre()
                            } label: {
                                HStack {
                                    Image(systemName: "bell")
                                    Text("通知設定")
                                }
                            }
/*                            NavigationLink{
                                PaginationTest()
                            } label: {
                                HStack {
                                    Image(systemName: "bell")
                                    Text("pagination test")
                                }
                            } */
                            HStack {
                                Image(systemName: "globe")
                                Picker("言語", selection: $selectedLanguage) {
                                    ForEach(countries) { country in
                                        Text("\(country.symbol) \(country.desc)").tag(country.tagname)
                                    }
                                }
                                .pickerStyle(.automatic)
                            }
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("ログアウト")
                            }
                            .onTapGesture {
                                pageSelection = 1
                                viewModel.signOut()
                            }
                            HStack {
                                Image(systemName: "person.fill.xmark")
                                    .foregroundColor(Color.red)
                                Text("アカウント削除")
                                    .foregroundColor(Color.red)
                            }
                            .onTapGesture {
                                // Show the confirmation dialog
                                showingDelUserConfirmation = true
                            }
                            .confirmationDialog("本当にアカウントを削除しますか？", isPresented: $showingDelUserConfirmation, titleVisibility: .visible) {
                                Button("削除", role: .destructive) {
                                    let deleteUid = viewModel.uid!
                                    print("Del user: \(deleteUid)")
                                    pageSelection = 1
                                    // Delete Account
                                    viewModel.deleteUser()
                                    // Delete from Firestore
                                    Task {
                                        do {
                                            // collection: "users"
                                            try await UserViewModel.deleteUser(deleteUid)
                                            // collection: "reports"
                                            try await ReportViewModel.deleteReportsByUid(deleteUid)
                                        } catch {
                                            // Handle error
                                            print("Failed to delete user or reports: \(error)")
                                        }
                                    }
                                }
                                Button("キャンセル", role: .cancel) { }
                            }
                        })
                   
                    Section(header: Text("利用規約"), content: {
                        NavigationLink {
                            TermsWebViewScreen()
                        } label: {
                            HStack {
                                Image(systemName: "doc.plaintext")
                                Text("利用規約")
                            }
                        }
                        NavigationLink {
                            PrivacyPolicyWebViewScreen()
                        } label: {
                            HStack {
                                Image(systemName: "character.book.closed.hi")
                                Text("プライバシーポリシー")
                            }
                        }
                    })
                    
                }
                
            }
            
            /* Text("Your uid: \(String(describing: viewModel.uid!))")
             .navigationBarBackButtonHidden(true)
             Button(action: {
             viewModel.signOut()
             }, label: {
             Text("ログアウト")
             .frame(maxWidth: .infinity)
             })
             .buttonStyle(.borderedProminent)
             .tint(.red)
             .padding()
             Spacer() */
        }
        .onAppear {
            debugPrint("Here we are sette!.")
            fetch()
        }
    }
    
    private func fetch () {
        Task {
            do {
                isLoading.toggle()
                debugPrint("### ###")
                debugPrint("### TEST ###")
                debugPrint("### ###")
                notifications = try await NotificationViewModel.fetchNotifications()
                if (viewModel.uid != nil) {
                    reportsByMe = try await ReportViewModel.fetchReportsByUid(viewModel.uid!)
                    // Get notification IDs for which the user has already sent a report
                    let reportedNotificationIds = Set(reportsByMe.map { $0.notificationId })
                    // Filter out notifications for which the user has already sent a report
                    availableNotifications = notifications.filter { !reportedNotificationIds.contains($0.notificationId) }
                    answeredNotifications = notifications.filter { reportedNotificationIds.contains($0.notificationId) }
                }
                isLoading.toggle()
                
/*                debugPrint(reportsByMe)
                debugPrint("And")
                debugPrint(reportedNotificationIds)
                debugPrint("And")
                debugPrint(availableNotifications) */
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
