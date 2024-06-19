//
//  helloswiftApp.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import SwiftUI
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      Messaging.messaging().delegate = self
      UNUserNotificationCenter.current().delegate = self
      
      // 1st launch
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
      
      application.registerForRemoteNotifications()

      return true
  }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("err: \(error)")
            } else if let token = token {
                print("got FCMToken: \(token)")
                Messaging.messaging().subscribe(toTopic: "notice_all")
            }
        }
    }
    
}


@main
struct helloswiftApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var rootViewModel = RootViewModel()  // Add this line
    @StateObject var firstPostEnqueteViewModel = FirstPostEnqueteViewModel()
    @StateObject var viewModel = AuthViewModel()
    //
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled = false
    @State private var homeViewRefreshID = UUID() // Unique ID for forcing HomeView refresh
    @State private var selectedNotificationId: String?
    @State private var refreshList = false

    var body: some Scene {
            WindowGroup {
                if (viewModel.isAuthenticated) {
                    HomeView(viewModel: viewModel)
                        .environmentObject(rootViewModel)  // Inject the environment object here
                        .environmentObject(firstPostEnqueteViewModel)
                        .applyAppearanceSetting(DarkModeSetting(rawValue: self.appearanceMode) ?? .followSystem)
                        .id(homeViewRefreshID) // Ensure HomeView is recreated when ID changes
                } else {
                    //                LoginView(viewModel: viewModel)
                    RootView()
                        .environmentObject(rootViewModel)  // Inject the environment object here
                        .environmentObject(firstPostEnqueteViewModel)
                        .applyAppearanceSetting(DarkModeSetting(rawValue: self.appearanceMode) ?? .followSystem)
           
                }
            }
            .onChange(of: viewModel.isAuthenticated) { _ in
                // Change the ID to force HomeView refresh on authentication change
                homeViewRefreshID = UUID()
            }
        }
}


extension View {
    @ViewBuilder
    func applyAppearanceSetting(_ setting: DarkModeSetting) -> some View {
        switch setting {
        case .followSystem:
            self
                .preferredColorScheme(.none)
        case .darkMode:
            self
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        case .lightMode:
            self
                .preferredColorScheme(.light)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    //@objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    //    print("Firebase token: ¥(String(describing: fcmToken))")
    //}
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
/*        print("Firebase reg token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )*/
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .list, .sound]])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        print(userInfo["notificationId"]!)
/*        var notificationId = userInfo["notificationId"] as? String {
            selectedNotificationId = notificationId
        } */
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
//        guard let data = userInfo["data"] as? [String: Any],
//              let newTitle = data["newTitle"]
        print("userInfo: \(userInfo)")

        return UIBackgroundFetchResult.newData
    }
}
