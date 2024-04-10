//
//  AppHomeScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

//import Foundation
import SwiftUI
//import MapKit
import CoreLocationUI

struct AppHomeScreen: View {
    // Location
//    @ObservedObject var manager = LocationManager()
//    @State var trackingMode = MapUserTrackingMode.follow
    @StateObject var locationClient = LocationClient()
    @State var notiTemplates: [NotiTemplateModel] = []
    @State var isLoading: Bool = false
    
    // sample
    private var students = [
        NotiTemplateModel(notiTitle: "AAA", notiBody: "A this is test"),
        NotiTemplateModel(notiTitle: "BBB", notiBody: "B this is test"),
    ]

    var body: some View {
        VStack {
            TopBar()
            Text("安否ホーム")
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
            }
            NavigationStack {
                List {
                    ForEach(notiTemplates, id: \.id) { e in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(e.createdAt!.dateValue(), format: .dateTime.month(.defaultDigits).day()) \(e.notiTitle)")
	//                                Text(e.notiTitle).bold()
                                Text(e.notiBody).foregroundStyle(.secondary)
                            }
                            .padding(.bottom, 1)
                        }
                    }
                }
                .navigationTitle("\(notiTemplates.count) 今までの通知")
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
        })
    }
    
    private func fetch () {
        Task {
            do {
                isLoading.toggle()
                notiTemplates = try await NotiTemplateViewModel.fetchNotiTemplates()
                isLoading.toggle()
                
                debugPrint(notiTemplates)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
