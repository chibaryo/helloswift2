import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import SwiftUI
import UserNotifications

@main
struct helloswiftApp: App {
    @StateObject var rootViewModel = RootViewModel()
    @StateObject var firstPostEnqueteViewModel = FirstPostEnqueteViewModel()
    @StateObject var viewModel = AuthViewModel()

    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled = false
    @State private var homeViewRefreshID = UUID() // Unique ID for forcing HomeView refresh
    @State private var selectedNotificationId: String?
    @State private var refreshList = false

    // AppDelegate instance
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if viewModel.isAuthenticated {
                HomeView(viewModel: viewModel)
                    .environmentObject(rootViewModel)
                    .environmentObject(firstPostEnqueteViewModel)
                    .applyAppearanceSetting(DarkModeSetting(rawValue: self.appearanceMode) ?? .followSystem)
                    .id(homeViewRefreshID)
            } else {
                RootView()
                    .environmentObject(rootViewModel)
                    .environmentObject(firstPostEnqueteViewModel)
                    .applyAppearanceSetting(DarkModeSetting(rawValue: self.appearanceMode) ?? .followSystem)
            }
        }
        .onChange(of: viewModel.isAuthenticated) { _ in
            homeViewRefreshID = UUID()
        }
        .onChange(of: appDelegate.deviceToken) { newToken in
            handleDeviceToken(newToken)
        }
    }

    // Handle APNS device token
    func handleDeviceToken(_ deviceToken: Data?) {
        guard let deviceToken = deviceToken else { return }
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
            } else if let token = token {
                print("FCM token: \(token)")
                Messaging.messaging().subscribe(toTopic: "notice_all")
            }
        }
    }
}

// AppDelegate to handle UIApplicationDelegate methods
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
//    static let shared = AppDelegate()

    @Published var deviceToken: Data?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase configured")

        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                print("Failed to request authorization for notifications: \(error)")
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // Executed even when the app is in background, or terminated
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("### BOOo!")
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print(userInfo["hoge"]) // -> fuga

        let userDefaults = UserDefaults.standard
//        let badgeCount = userDefaults.integer(forKey: "yourNotAnsweredNotiCounts")

        application.applicationIconBadgeNumber += 1
//        UIApplication.shared.applicationIconBadgeNumber = badgeCount + 1
        if application.applicationState == .background || application.applicationState == .inactive {
            print("badge will be automatically updated by firestore listener!")
//            UIApplication.shared.applicationIconBadgeNumber = badgeCount
        } else {
            // Debug
            //let userDefaults = UserDefaults.standard
            //let badgeCount = userDefaults.integer(forKey: "yourNotAnsweredNotiCounts")
            
//            application.applicationIconBadgeNumber += 1
        }

        // Task (max. 30secs)
//        let userDefaults = UserDefaults.standard
//        UIApplication.shared.applicationIconBadgeNumber = 92

        //application.applicationIconBadgeNumber += 1
        //application.applicationIconBadgeNumber += 1
        completionHandler(.newData) // 処理結果をiOSに報告するのを忘れずに
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .list, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
        print(userInfo["notificationId"] ?? "No notification ID")

        completionHandler()
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase reg token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}


extension View {
    @ViewBuilder
    func applyAppearanceSetting(_ setting: DarkModeSetting) -> some View {
        switch setting {
        case .followSystem:
            self.preferredColorScheme(.none)
        case .darkMode:
            self.preferredColorScheme(.dark)
        case .lightMode:
            self.preferredColorScheme(.light)
        }
    }
}
