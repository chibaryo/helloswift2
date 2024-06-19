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
    @AppStorage("isNotiTokyoEnabled") var isNotiTokyoEnabled: Bool = false
    @AppStorage("isNotiNagoyaEnabled") var isNotiNagoyaEnabled: Bool = false
    @AppStorage("isNotiOsakaEnabled") var isNotiOsakaEnabled: Bool = false
    @AppStorage("isNotiTest2024Enabled") var isNotiTest2024Enabled: Bool = false

    var body: some View {
        VStack {
            Text("Toggle Topic")
            Toggle(isOn: $isNotiTokyoEnabled) {
                Text("東京")
            }.tint(.purple)
                .onChange(of: isNotiTokyoEnabled) { value in
                    if (value) {
                        print("reg tokyo")
                        Messaging.messaging().subscribe(toTopic: "notice_tokyo")
                    } else {
                        print("unreg tokyo")
                        Messaging.messaging().unsubscribe(fromTopic: "notice_tokyo")
                    }
                }
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
            Toggle(isOn: $isNotiTest2024Enabled) {
                Text("test_2024")
            }.tint(.purple)
                .onChange(of: isNotiTest2024Enabled) { value in
                    if (value) {
                        print("reg test_2024")
                        Messaging.messaging().subscribe(toTopic: "test_2024")
                    } else {
                        print("unreg")
                        Messaging.messaging().unsubscribe(fromTopic: "test_2024")
                    }
                }
        }
        .padding()
    }
}
