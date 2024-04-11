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

struct AppHomeScreen: View {
    // Location
//    @ObservedObject var manager = LocationManager()
//    @State var trackingMode = MapUserTrackingMode.follow
    @StateObject var locationClient = LocationClient()
    @State var notifications: [NotificationModel] = []
    @State var availableNotifications: [NotificationModel] = []
    @State var reportsByMe: [ReportModel] = []
    @State var isLoading: Bool = false
    var viewModel: AuthViewModel
    //
    @State private var path = [Path]()
    //
    @State private var refreshList = false

    var body: some View {
        VStack {
            TopBar()
/*            Text("安否ホーム")
            VStack {
                Text("[位置情報]")
                if let location = locationClient.location {
                    Text("緯度: \(location.latitude)")
                    Text("経度: \(location.longitude)")
                    Text("address: \(locationClient.address)")
                } else {
                    Text("緯度: ----")
                    Text("経度: ----")
                }
            }
            LocationButton(.currentLocation) {
                locationClient.requestLocation()
            }
            .foregroundColor(.white)
            .cornerRadius(30)
            if (locationClient.requesting) {
                ProgressView()
            } */
            NavigationStack {
                List {
                    ForEach(availableNotifications, id: \.self.notificationId) { e in
                        VStack(alignment: .leading) {
                            NavigationLink {
                                PostEnqueteView(viewModel: viewModel, notification: e, refreshList: self.$refreshList)
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
                .navigationTitle("\(availableNotifications.count) 未回答の通知")
                .toolbar {
                    ToolbarItem{
                        Button(action: {
                            
                        }){
                            Label("Add enquete", systemImage: "plus")
                        }
                    }
                }
            }
            Spacer()
        }
        .onAppear(perform: {
            fetch()
            locationClient.requestLocation()
        })
        .onChange(of: refreshList) { _ in
            // Fetch data whenever refreshList changes
            fetch()
        }
    }
    
    private func fetch () {
        Task {
            do {
                isLoading.toggle()
                notifications = try await NotificationViewModel.fetchNotifications()
                reportsByMe = try await ReportViewModel.fetchReportsByUid(viewModel.uid!)
                // Get notification IDs for which the user has already sent a report
                let reportedNotificationIds = Set(reportsByMe.map { $0.notificationId })
                // Filter out notifications for which the user has already sent a report
                availableNotifications = notifications.filter { !reportedNotificationIds.contains($0.notificationId.uuidString) }
                isLoading.toggle()
                
                debugPrint(reportsByMe)
                debugPrint("And")
                debugPrint(reportedNotificationIds)
                debugPrint("And")
                debugPrint(availableNotifications)
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


