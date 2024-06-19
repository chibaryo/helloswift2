//
//  FirstPostEnquete.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/06/19.
//

import SwiftUI

let rselectInjuryStatus: [RadioGroup] = [
    RadioGroup(index: 0, desc: "無事"),
    RadioGroup(index: 1, desc: "怪我"),
    RadioGroup(index: 2, desc: "その他")
]
let rselectAttendOfficeStatus: [RadioGroup] = [
    RadioGroup(index: 0, desc: "出社可"),
    RadioGroup(index: 1, desc: "出社不可"),
    RadioGroup(index: 2, desc: "出社済")
]


struct FirstPostEnquete: View {
    @EnvironmentObject var firstPostEnqueteViewModel: FirstPostEnqueteViewModel
    var authViewModel: AuthViewModel
    @State private var isChecked: Bool = false

    @State private var pageNum: Int = 1
    @State private var rselectedInjuryIndex: Int = 100
    @State private var rselectedAttendOfficeIndex: Int = 100
    
    @State private var injuryStatus: String = ""
    @State private var attendOfficeStatus: String = ""
    @State private var rmessage: String = ""
    //
    @State private var isLocationChecked: Bool = false
    @StateObject var locationClient = LocationClient()

    @Environment(\.presentationMode) var presentationMode
    // FocusState
    @FocusState var isKbdFocused: Bool

    var body: some View {
        VStack {
            if let notificationId = firstPostEnqueteViewModel.notificationId {
                Section {
                    Text("Post Enquete View with ID: \(notificationId)")
                    HStack {
                        Text("title")
                        Text(firstPostEnqueteViewModel.notiTitle ?? "")
                    }
                    HStack {
                        Text("body")
                        Text(firstPostEnqueteViewModel.notiBody ?? "")
                    }
                }
                if firstPostEnqueteViewModel.notiType == "confirmation" {
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
                                        notificationId: notificationId,
                                        uid: authViewModel.uid!,
                                        injuryStatus: "",
                                        attendOfficeStatus: "",
                                        location: "",
                                        //location: isChecked ? locationClient.address : "",
                                        message: "",
                                        isConfirmed: isChecked ? true : false
                                    )

                                    try await ReportViewModel.addReport(doc)
                                    // Return Home
                                    //refreshList = true
                                    //presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            Text("送信")
                                .id("SubmitButton")
                        }
                    }
                }
                else if firstPostEnqueteViewModel.notiType == "enquete" {
//                    Text("Enquete")
                    Section
                    {
                            ForEach(0..<rselectInjuryStatus.count, id: \.self, content: { index in
                                HStack {
                                    Image(systemName: rselectedInjuryIndex == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    Text(rselectInjuryStatus[index].desc).tag(rselectInjuryStatus[index].desc)
                                    Spacer()
                                }
                                .frame(height: 20)
                                .onTapGesture{
                                    rselectedInjuryIndex = index
                                    self.injuryStatus = rselectInjuryStatus[index].desc
                                    print("injuryStatus: \(self.injuryStatus)")
                                }
                            })
                            Divider()
                                .background(.orange)
                                .padding(.horizontal, 4 )
                            ForEach(0..<rselectAttendOfficeStatus.count, id: \.self, content: { index in
                                HStack {
                                    Image(systemName: rselectedAttendOfficeIndex == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    Text(rselectAttendOfficeStatus[index].desc).tag(rselectAttendOfficeStatus[index].desc)
                                    Spacer()
                                }
                                .frame(height: 20)
                                .onTapGesture{
                                    rselectedAttendOfficeIndex = index
                                    self.attendOfficeStatus = rselectAttendOfficeStatus[index].desc
                                }
                            })
                            // Page 2
                            Text("メッセージ入力（任意）")
                            Button("キーボードを閉じる") {
                                self.isKbdFocused = false
                            }
                            TextEditor(text: $rmessage)
                                .focused(self.$isKbdFocused)
                                .frame(width: 250, height: 50)
                                .border(.gray)
                                .id("TextEditor")
                            Toggle(isOn: $isLocationChecked) {
                                Text("位置情報を送信する")
                            }
                            .toggleStyle(.checkBox)
                            Button(action: {
                                Task {
                                    do {
                                        let doc = ReportModel(
                                            notificationId: notificationId,
                                            uid: authViewModel.uid!,
                                            injuryStatus: self.injuryStatus,
                                            attendOfficeStatus: self.attendOfficeStatus,
                                            location: isChecked ? locationClient.address : "",
                                            message: self.rmessage,
                                            isConfirmed: true
                                        )

                                        try await ReportViewModel.addReport(doc)
                                        print(locationClient.address)
                                        // Return Home
                                        //refreshList = true
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
        .onDisappear(perform: {
            firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
        })
    }
}

/*
#Preview {
    FirstPostEnquete()
}
*/
