//
//  SecondEnqueteView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/11.
//

import Foundation
import SwiftUI

struct SecondEnqueteView: View {
    @StateObject var locationClient = LocationClient()
    //var uid: String
    var viewModel: AuthViewModel
    var notification: NotificationModel

    var injuryStatus: String
    var attendOfficeStatus: String
    @State private var message: String = ""
    @State var reports: [ReportModel] = []
    //
    @State private var isChecked: Bool = false
    @State private var isAppHomePresented: Bool = false
    // Add missing arguments as state variables
    @State private var notifications: [NotificationModel] = []
    @State private var answeredNotifications: [NotificationModel] = []
    @State private var availableNotifications: [NotificationModel] = []
    @State private var reportsByMe: [ReportModel] = []
    @State private var isLoading: Bool = false
    @State private var badgeManager = AppAlertBadgeManager(application: UIApplication.shared)
    @State private var user: UserModel?

    var body: some View {
        NavigationStack {
            VStack {
                Text(locationClient.address)
                Text("メッセージ入力（任意）")
                TextEditor(text: $message)
                    .frame(width: 250, height: 250)
                    .border(.gray)
                Toggle(isOn: $isChecked) {
                    Text("位置情報を送信する")
                }
                .toggleStyle(.checkBox)
                Button(action: {
                    Task {
                        do {
                               let doc = ReportModel(
                                   notificationId: notification.notificationId,
                                   uid: viewModel.uid!,
                                   injuryStatus: injuryStatus,
                                   attendOfficeStatus: attendOfficeStatus,
                                   location: isChecked ? locationClient.address : "",
                                   message: message,
                                   isConfirmed: true
                               )
                               try await ReportViewModel.addReport(doc)
                            // Return Home
                            isAppHomePresented = true
                        }
                    }
                }) {
                    Text("送信")
                }
            }
        }
        .navigationDestination(isPresented: $isAppHomePresented){
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
        }
        .onAppear {
            fetchInitialData()
        }
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

}


public struct CheckBoxStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button {
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            }
            .foregroundStyle(configuration.isOn ? Color.accentColor : Color.primary)

            configuration.label
        }
    }
}

extension ToggleStyle where Self == CheckBoxStyle {
    public static var checkBox: CheckBoxStyle {
        .init()
    }
}
