//
//  AppHomeScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

//import Foundation
import SwiftUI
//import MapKit
import FirebaseFirestore
import CoreLocationUI
import SlidingTabView

struct AppHomeScreen: View {
    @EnvironmentObject var firstPostEnqueteViewModel: FirstPostEnqueteViewModel
    // Location
//    @ObservedObject var manager = LocationManager()
//    @State var trackingMode = MapUserTrackingMode.follow
    @StateObject var locationClient = LocationClient()
    @State private var address: String = ""

/*    @State var notifications: [NotificationModel] = []
    @State var answeredNotifications: [NotificationModel] = []
    @State var availableNotifications: [NotificationModel] = [] */
    @Binding var notifications: [NotificationModel]
    @Binding var answeredNotifications: [NotificationModel]
    @Binding var availableNotifications: [NotificationModel]
    @Binding var reportsByMe: [ReportModel]
    @Binding var isLoading: Bool
    @Binding var user: UserModel?
//    @State var reportsByMe: [ReportModel] = []
//    @State var isLoading: Bool = false
    var viewModel: AuthViewModel
    //
    @State private var path = [Path]()
    //
    @State private var refreshList = false
    // App Badge
    @State var badgeManager = AppAlertBadgeManager(application: UIApplication.shared)
    // TabView
    @State private var tabIndex: Int = 0
    // Alert
    @State private var presentShowReportAlert: Bool = false
    @State private var selectedNotification: NotificationModel?

    var body: some View {
        ScrollViewReader { sp in
                VStack {
                    TopBar()
        //            Text("安否ホーム")
                    VStack {
        //                Text("[位置情報]")
                        if let location = locationClient.location {
                            // Text("緯度: \(location.latitude)")
                            // Text("経度: \(location.longitude)")
                            Text("address: \(locationClient.address)")
                        } else {
                            // Text("緯度: ----")
                            // Text("経度: ----")
                        }
                    }
                    LocationButton(.currentLocation) {
                        locationClient.requestLocation()
                    }
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    if (locationClient.requesting) {
                        ProgressView()
                    }
                    // TabView
                    SlidingTabView(
                        selection: $tabIndex,
                        tabs:
                            [
                                "未回答",
                                "回答済み"
                            ],
                        animation: .easeInOut
                    )
        //            Spacer()
                    if tabIndex == 0 {
                        Text("未回答の通知 (\(availableNotifications.count))")
                        NavigationStack {
                            List {
                                ForEach(availableNotifications, id: \.self.notificationId) { e in
                                        Button {
                                            selectNotification(e)
                                        } label: {
                                            HStack {
                                                Text("\(formatDate(e.createdAt)) \(e.notiTitle)").tag(e.notificationId)
                                                Text(e.notiBody.prefix(10) + (e.notiBody.count > 10 ? "..." : "")).foregroundStyle(.secondary)
                                            }
                                            .padding(.bottom, 1)
                                        }
                                    }
                            }
                            .navigationTitle("未回答の通知 (\(availableNotifications.count))")
                            .navigationDestination(isPresented: $firstPostEnqueteViewModel.isActiveFirstPostEnqueteView) {
                                if let selectedNotification = selectedNotification {
                                    FirstPostEnquete(
                                        authViewModel: viewModel
                                    )
                                    .environmentObject(firstPostEnqueteViewModel)
                                    .onDisappear {
                                        firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
                                        debugPrint("FirstPostEnquete disappeared, isActiveFirstPostEnqueteView reset to false")
                                    }
                                }
                            }
                        }
                    } else if tabIndex == 1 {
                        // 回答済みTab
                        NavigationStack {
                            List {
                                ForEach(answeredNotifications, id: \.self.notificationId) { e in
                                    VStack(alignment: .leading) {
                                        NavigationLink {
                                            ReportDetailView(viewModel: viewModel, notification: e) // , refreshList: self.$refreshList
                                        } label: {
                                            HStack {
                                                Text("\(formatDate(e.createdAt)) \(e.notiTitle)").tag(e.notificationId)
                                                //Text("\(e.createdAt!.dateValue(), format: .dateTime.month(.defaultDigits).day()) \(e.notiTitle)")
                    //                                Text(e.notiTitle).bold()
                                                //Text(e.notiBody).foregroundStyle(.secondary)
                                                Text(e.notiBody.prefix(10) + (e.notiBody.count > 10 ? "..." : "")).foregroundStyle(.secondary)

                                            }
                                            .padding(.bottom, 1)
                                        }
                                    }
                                }
                            }
            /*                .navigationDestination(for: notifications.self) { noti in
                                PostEnqueteView(viewModel: viewModel, notification: selectedNotification)
                            } */
                            .navigationTitle("回答済みの通知 (\(answeredNotifications.count))")
        /*                    .toolbar {
                                ToolbarItem{
                                    Button(action: {
                                        
                                    }){
                                        Label("Add enquete", systemImage: "plus")
                                    }
                                }
                            } */
                        }
                    }
                    // End TabView
                    Spacer()
                }

        }
        .onAppear(perform: {
//            fetch()
            locationClient.requestLocation()
            badgeManager.setAlertBadge(number: availableNotifications.count)
        })
        .onChange(of: refreshList) { _ in
            // Fetch data whenever refreshList changes
            fetch()
        }
    }
    
    private func selectNotification(_ notification: NotificationModel) {
        // turn on true and
            firstPostEnqueteViewModel.notiTitle = notification.notiTitle
            firstPostEnqueteViewModel.notiBody = notification.notiBody
            firstPostEnqueteViewModel.notiType = notification.notiType
            firstPostEnqueteViewModel.notificationId = notification.notificationId
            debugPrint("firstPostEnqueteViewModel.notificationId: \(String(describing: firstPostEnqueteViewModel.notificationId))")
            selectedNotification = notification
            firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = true
            debugPrint("firstPostEnqueteViewModel.isActiveFirstPostEnqueteView: \(String(describing: firstPostEnqueteViewModel.isActiveFirstPostEnqueteView))")
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
    
    private func formatDate(_ timestamp: Timestamp?) -> String {
        guard let timestamp = timestamp else {
            return "Date unknown"
        }
        
        let date = timestamp.dateValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "[M/dd HH:mm]" // Use MM for month, dd for day, HH for 24-hour format, mm for minutes
        return dateFormatter.string(from: date)
    }
}


