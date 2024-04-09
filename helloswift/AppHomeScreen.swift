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
/*            Map(coordinateRegion: $manager.region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode)
            .edgesIgnoringSafeArea(.bottom)
*/
            Spacer()
        }
    }
}
