//
//  LoginScreen.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import SwiftUI
import FirebaseMessaging

struct ToggleNotiGenre: View {
    @AppStorage("isNotiNagoyaEnabled") var isNotiNagoyaEnabled: Bool = false
    @AppStorage("isNotiOsakaEnabled") var isNotiOsakaEnabled: Bool = false

    var body: some View {
        VStack {
            Text("Toggle Topic")
            Toggle(isOn: $isNotiNagoyaEnabled) {
                Text("名古屋")
            }.tint(.purple)
                .onChange(of: isNotiNagoyaEnabled) { value in
                    if (value) {
                        print("reg nagyoa")
                        Messaging.messaging().subscribe(toTopic: "notice_nagoya")
                    } else {
                        print("unreg")
                        Messaging.messaging().unsubscribe(fromTopic: "notice_nagoya")
                    }
                }
            Toggle(isOn: $isNotiOsakaEnabled) {
                Text("大阪")
            }.tint(.purple)
                .onChange(of: isNotiOsakaEnabled) { value in
                    if (value) {
                        print("reg osaka")
                        Messaging.messaging().subscribe(toTopic: "notice_osaka")
                    } else {
                        print("unreg")
                        Messaging.messaging().unsubscribe(fromTopic: "notice_osaka")
                    }
                }
        }
        .padding()
    }
}
