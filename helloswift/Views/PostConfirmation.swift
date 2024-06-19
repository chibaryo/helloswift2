//
//  UpdateTemplateButton.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/10.
//

import Foundation
import SwiftUI
import StepperView
import CoreLocationUI

struct PostConfirmation: View {
    var sp: ScrollViewProxy
    var viewModel: AuthViewModel
    var notification: NotificationModel

    @Environment(\.presentationMode) var presentationMode
    @Binding var refreshList: Bool // Binding for refreshList
    @State private var isChecked: Bool = false

    // FocusState
    @FocusState var isFocused: Bool

    var body: some View {
        VStack {
            //notiinfo
            Section {
                HStack {
                    Text("タイトル: \(notification.notiTitle)")
                    Spacer()
                }
                HStack {
                    Text("本文: \(notification.notiBody)")
                    Spacer()
                }
            }
            Section
            {
                Toggle(isOn: $isChecked) {
                    Text("確認しました")
                }
                .toggleStyle(.checkBox)
                Button(action: {
                    Task {
                        do {
                            let doc = ReportModel(
                                notificationId: notification.notificationId,
                                uid: viewModel.uid!,
                                injuryStatus: "",
                                attendOfficeStatus: "",
                                location: "",
                                //location: isChecked ? locationClient.address : "",
                                message: "",
                                isConfirmed: isChecked ? true : false
                            )

                            try await ReportViewModel.addReport(doc)
                            // Return Home
                            refreshList = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("送信")
                        .id("SubmitButton")
                }

            }
        }
    }

}
