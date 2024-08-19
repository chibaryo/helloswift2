//
//  HomeView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    //@State var selection = 1
    @AppStorage(wrappedValue: 1, "pageSelection") var pageSelection
    @State var isActive: Bool = false
    var viewModel: AuthViewModel
    @EnvironmentObject var firstPostEnqueteViewModel: FirstPostEnqueteViewModel
//
    @StateObject var locationClient = LocationClient()
    @State private var address: String = ""
    @State var notifications: [NotificationModel] = []
    @State var answeredNotifications: [NotificationModel] = []
    @State var availableNotifications: [NotificationModel] = []
    @State var reportsByMe: [ReportModel] = []
    @State var isLoading: Bool = false
    @State var badgeManager = AppAlertBadgeManager(application: UIApplication.shared)
    //
    @State private var user: UserModel?
    @State private var selectedNotificationId: String = ""

    @State private var hasLoadedData = false  // New state variable to track data loading
    @State var didAppear = false

    // Firestore listener
    @State private var listener: ListenerRegistration?
    @State private var refreshList = false
    
    //
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            TabView(selection: $pageSelection) {
                AppHomeScreen(
                    locationClient: locationClient,
                    notifications: $notifications,
                    answeredNotifications: $answeredNotifications,
                    availableNotifications: $availableNotifications,
                    reportsByMe: $reportsByMe,
                    isLoading: $isLoading,
                    user: $user,
                    viewModel: viewModel,
                    badgeManager: badgeManager
                )
                    .tabItem {
                        Label("ホーム", systemImage: "house")
                    }
                    .tag(1)
                SettingsScreen(
                    viewModel: viewModel,
                    user: $user,
                    notifications: $notifications,
                    answeredNotifications: $answeredNotifications,
                    availableNotifications: $availableNotifications,
                    reportsByMe: $reportsByMe
                )
                    .tabItem {
                        Label("設定", systemImage: "person.crop.circle")
                    }
                    .tag(2)
            }
            .navigationDestination(isPresented: $firstPostEnqueteViewModel.isActiveFirstPostEnqueteView) {
                FirstPostEnquete(
                    authViewModel: viewModel , refreshList: self.$refreshList //, refreshList: <#Binding<Bool>#>
                )
                .environmentObject(firstPostEnqueteViewModel)
                .onDisappear {
                     firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
                     debugPrint("FirstPostEnquete disappeared, isActiveFirstPostEnqueteView reset to false")
                    
                    
                    fetchData()
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("active!")
            case .inactive:
                print("inactive!")
            case .background:
                print("background!")
                pageSelection = 1
            @unknown default:
                print("@unknown")
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didReceiveRemoteNotification"))) { notification in
            if
                let userInfo = notification.userInfo,
                let aps = userInfo["aps"] as? [AnyHashable: Any],
                let alert = aps["alert"] as? [AnyHashable: Any],
                let title = alert["title"] as? String,
                let body = alert["body"] as? String,
                let notificationId = userInfo["notificationId"] as? String,
                let notiType = userInfo["type"] as? String
                {
                debugPrint("title: \(title)")
                debugPrint("body: \(body)")
                debugPrint("notificationId: \(notificationId)")
                debugPrint("notiType: \(notiType)")
                
                // Goto
                DispatchQueue.main.async {
                    firstPostEnqueteViewModel.notiTitle = title
                    firstPostEnqueteViewModel.notiBody = body
                    firstPostEnqueteViewModel.notiType = notiType
                    firstPostEnqueteViewModel.notificationId = notificationId
                    // Add location
                    //firstPostEnqueteViewModel.locationString =
                    debugPrint("firstPostEnqueteViewModel.notificationId: \(String(describing: firstPostEnqueteViewModel.notificationId))")
                    firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = true
                    debugPrint("firstPostEnqueteViewModel.isActiveFirstPostEnqueteView: \(String(describing: firstPostEnqueteViewModel.isActiveFirstPostEnqueteView))")
                }
            }
        }
        .onAppear {
            debugPrint("Here we are home!.")
            fetchData()
            if !didAppear {
                fetchData()
                 //This is where I loaded my coreData information into normal arrays
             }
             didAppear = true
/*            if !hasLoadedData {
                fetchData()
                hasLoadedData = true
            } */
            
            listenForUpdates()
        }
        .onChange(of: viewModel.isAuthenticated) { isAuthenticated in
            fetchData()
            if !didAppear {
                fetchData()
            }
            didAppear = true
/*            if isAuthenticated {
                fetchData()
            } else {
                resetData()
            } */
        }
        /* NavigationStack {
         VStack {
         Text("Your uid: \(String(describing: viewModel.uid!))")
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
         }
         } */
    }

    private func listenForUpdates() {
        // Set up Firestore listener to observe changes in the collection
        listener = Firestore.firestore().collection("notifications")
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    if let error = error {
                        print("Error fetching snapshots: \(error)")
                    }
                    return
                }
                
                // Parse snapshot data into NotiTemplateModel objects
                do {
                    let notifications = try snapshot.documents.compactMap { try $0.data(as: NotificationModel.self) }
                    self.notifications = notifications
                } catch {
                    print("Error decoding snapshot: \(error)")
                }
            }
    }


    private func resetData() {
        notifications = []
        answeredNotifications = []
        availableNotifications = []
        reportsByMe = []
        hasLoadedData = false
    }

    private func fetchInitialData() {
            Task {
                do {
                    isLoading = true
                    notifications = try await NotificationViewModel.fetchNotifications()
                    if let uid = viewModel.uid {
                        reportsByMe = try await ReportViewModel.fetchReportsByUid(uid)
                        let reportedNotificationIds = Set(reportsByMe.map { $0.notificationId })
                        availableNotifications = notifications.filter { !reportedNotificationIds.contains($0.notificationId) }
                        answeredNotifications = notifications.filter { reportedNotificationIds.contains($0.notificationId) }
                    }
                    isLoading = false
                    badgeManager.setAlertBadge(number: availableNotifications.count)
                } catch {
                    debugPrint(error.localizedDescription)
                    isLoading = false
                }
            }
        }
    
    private func fetchData () {
        Task {
            do {
                isLoading.toggle()
                debugPrint("### ###")
                notifications = try await NotificationViewModel.fetchNotifications()
                 if let uid = viewModel.uid {
                     debugPrint("### prepre-TEST ###")
                     reportsByMe = try await ReportViewModel.fetchReportsByUid(uid)
                     let reportedNotificationIds = Set(reportsByMe.map { $0.notificationId })
                     availableNotifications = notifications.filter { !reportedNotificationIds.contains($0.notificationId) }
                     answeredNotifications = notifications.filter { reportedNotificationIds.contains($0.notificationId) }
                 }
                 badgeManager.setAlertBadge(number: availableNotifications.count)

                // Fetch login user data
                user = try await UserViewModel.revisedFetchUserByUid(documentId: viewModel.uid!)
                debugPrint(user!)

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
