//
//  LocationClient.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/09.
//

import Foundation
import CoreLocation

class LocationClient: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var requesting: Bool = false
    @Published var address: String = ""
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        request()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        request()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geocoder = CLGeocoder()

        location = locations.first?.coordinate
        let getMovedMapCenter: CLLocation = CLLocation(latitude: location!.latitude, longitude: location!.longitude)

        geocoder.reverseGeocodeLocation(getMovedMapCenter) { placeMarks, error in
            if let firstPlaceMark = placeMarks?.first {
                print("Pref: \(String(describing: firstPlaceMark.administrativeArea))")
                self.address.append(firstPlaceMark.administrativeArea!)
                self.address.append(firstPlaceMark.locality!)
                self.address.append(firstPlaceMark.subLocality ?? "")
            }
        }
        requesting = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        requesting = false
    }
    
    private func request() {
        if (locationManager.authorizationStatus == .authorizedWhenInUse) {
            requesting = true
            locationManager.requestLocation()
        }
    }
}
