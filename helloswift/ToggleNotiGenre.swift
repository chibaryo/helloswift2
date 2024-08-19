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
    @AppStorage("isNotiOsakaEnabled") var isNotiOsakaEnabled: Bool = false
    @AppStorage("isNotiNagoyaEnabled") var isNotiNagoyaEnabled: Bool = false
    @AppStorage("isNotiHiroshimaEnabled") var isNotiHiroshimaEnabled: Bool = false
    @AppStorage("isNotiOkayamaEnabled") var isNotiOkayamaEnabled: Bool = false
    @AppStorage("isNotiKyushuEnabled") var isNotiKyushuEnabled: Bool = false

    @AppStorage("isNotiTestAdm2024Enabled") var isNotiTestAdm2024Enabled: Bool = false

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
            Toggle(isOn: $isNotiHiroshimaEnabled) {
                Text("広島")
            }.tint(.purple)
                .onChange(of: isNotiHiroshimaEnabled) { value in
                    if (value) {
                        print("reg hiroshima")
                        Messaging.messaging().subscribe(toTopic: "notice_hiroshima")
                    } else {
                        print("unreg")
                        Messaging.messaging().unsubscribe(fromTopic: "notice_hiroshima")
                    }
                }
            Toggle(isOn: $isNotiOkayamaEnabled) {
                Text("岡山")
            }.tint(.purple)
                .onChange(of: isNotiOkayamaEnabled) { value in
                    if (value) {
                        print("reg okayama")
                        Messaging.messaging().subscribe(toTopic: "notice_okayama")
                    } else {
                        print("unreg")
                        Messaging.messaging().unsubscribe(fromTopic: "notice_okayama")
                    }
                }
            Toggle(isOn: $isNotiKyushuEnabled) {
                Text("九州")
            }.tint(.purple)
                .onChange(of: isNotiKyushuEnabled) { value in
                    if (value) {
                        print("reg kyushu")
                        Messaging.messaging().subscribe(toTopic: "notice_kyushu")
                    } else {
                        print("unreg")
                        Messaging.messaging().unsubscribe(fromTopic: "notice_kyushu")
                    }
                }
            Toggle(isOn: $isNotiTestAdm2024Enabled) {
                Text("管理者テスト2024")
            }.tint(.purple)
                .onChange(of: isNotiTestAdm2024Enabled) { value in
                    if (value) {
                        print("reg testadm2024")
                        Messaging.messaging().subscribe(toTopic: "test_adm_2024")
                    } else {
                        print("unreg")
                        Messaging.messaging().unsubscribe(fromTopic: "test_adm_2024")
                    }
                }
        }
        .padding()
    }
}
