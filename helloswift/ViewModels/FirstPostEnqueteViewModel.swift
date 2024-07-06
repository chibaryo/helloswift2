//
//  FirstPostEnqueteViewModel.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/06/19.
//

import SwiftUI
import Combine

class FirstPostEnqueteViewModel: ObservableObject {
    @Published var isActiveFirstPostEnqueteView = false
    @Published var notificationId: String? = nil
    @Published var notiTitle: String? = nil
    @Published var notiBody: String? = nil
    @Published var notiType: String? = nil
//    @Published var locationString: String? = nil

    var title = ""
    var body = ""
    
    var cancellable: AnyCancellable?
    
    init () {
        cancellable = NotificationCenter.default
            .publisher(for: Notification.Name("didReceiveRemoteNotification"))
            .sink { notification in
                debugPrint("notification ini in: \(notification)")
                if let userInfo = notification.userInfo {
                    debugPrint("userInfo: \(userInfo)")
                    self.title = "Foo!"
                    self.body = "Bar!"
                    self.isActiveFirstPostEnqueteView = true
                }
            }
    }
}
