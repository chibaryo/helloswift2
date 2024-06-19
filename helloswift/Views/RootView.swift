//
//  RootView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/17.
//
import Foundation
import SwiftUI
import SlidingTabView

struct RootView: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var firstPostEnqueteViewModel: FirstPostEnqueteViewModel

    @State private var tabIndex: Int = 0
    @StateObject var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
                    VStack {
                        // Main content of ContentView
                        SlidingTabView(
                            selection: $tabIndex,
                            tabs:
                                        [
                                            "ログイン",
                                            "サインアップ"
                                        ],
                            animation: .easeInOut
                        )
                        Spacer()
                        if tabIndex == 0 {
                            LoginView(viewModel: viewModel)
                        } else if tabIndex == 1 {
                            SignupView(viewModel: viewModel)
                        }
                    }

/*                    .navigationDestination(isPresented: $firstPostEnqueteViewModel.isActiveFirstPostEnqueteView) {
                        FirstPostEnquete()
                            .environmentObject(firstPostEnqueteViewModel)
                    } */
                }
        /* .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didReceiveRemoteNotification"))) { notification in
            if
                let userInfo = notification.userInfo,
                let aps = userInfo["aps"] as? [AnyHashable: Any],
                let alert = aps["alert"] as? [AnyHashable: Any],
                let title = alert["title"] as? String,
                let body = alert["body"] as? String,
                let notificationId = userInfo["notificationId"] as? String,
                let notiType = userInfo["type"] as? String
                {
                debugPrint("userInfo: \(userInfo)")
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
                    debugPrint("firstPostEnqueteViewModel.notificationId: \(String(describing: firstPostEnqueteViewModel.notificationId))")
                    firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = true
                    debugPrint("firstPostEnqueteViewModel.isActiveFirstPostEnqueteView: \(String(describing: firstPostEnqueteViewModel.isActiveFirstPostEnqueteView))")
                }
            }
        } */

        }
//        .environmentObject(FirstPostEnqueteViewModel())
 }
/*
import Foundation
import SwiftUI
import SlidingTabView

struct RootView: View {
    @State private var tabIndex: Int = 0
    @StateObject var viewModel = AuthViewModel()

    var body: some View {
        VStack {
            SlidingTabView(
                selection: $tabIndex,
                tabs:
                            [
                                "ログイン",
                                "サインアップ"
                            ],
                animation: .easeInOut
            )
            Spacer()
            if tabIndex == 0 {
                LoginView(viewModel: viewModel)
            } else if tabIndex == 1 {
                SignupView(viewModel: viewModel)
            }
        }
    }
}
*/

 /*
struct RootView: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            if authViewModel.isAuthenticated {
                if let selectedNotificationId = rootViewModel.selectedNotificationId {
                    NavigationLink(destination: FirstPostEnquete(
                        selectedNotificationId: selectedNotificationId
                    ), isActive: .constant(true)) {
                        EmptyView()
                    }
                } else {
                    HomeView(viewModel: authViewModel)
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
/*        .onChange(of: authViewModel.isAuthenticated) { _ in
            if authViewModel.isAuthenticated {
                authViewModel.selectedNotificationId = nil
            }
        } */
    }
}

*/
