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

struct RadioGroup: Identifiable, Hashable {
    var index: Int
    var desc: String
    var id: String { self.desc }
}

struct EnquetePostData: Identifiable, Hashable {
    var uid: String
    var location: String
    var injuryStatus: String
    var attendOfficeStatus: String
    var id: String { self.uid }
}

let selectInjuryStatus: [RadioGroup] = [
    RadioGroup(index: 0, desc: "無事"),
    RadioGroup(index: 1, desc: "怪我"),
    RadioGroup(index: 2, desc: "その他")
]
let selectAttendOfficeStatus: [RadioGroup] = [
    RadioGroup(index: 0, desc: "出社可"),
    RadioGroup(index: 1, desc: "出社不可"),
    RadioGroup(index: 2, desc: "出社済")
]

struct PostEnqueteView: View {
    var sp: ScrollViewProxy
    var viewModel: AuthViewModel
//    var notification: NotificationModel
    var selectedNotificationId: String
    @State private var presentEditAlert: Bool = false
    @State private var inputNotiTitle: String = ""
    @State private var inputNotiBody: String = ""
    @State private var currentDocId: String = ""
    @State var user: UserModel?
    @State var notification: NotificationModel?
    @State var notitemplate: NotiTemplateModel?
    @State private var pageNum: Int = 1
    @StateObject var locationClient = LocationClient()
    @State private var message: String = ""
    @State var reports: [ReportModel] = []
    //
    @State private var isChecked: Bool = false
    @State private var isAppHomePresented: Bool = false
    
    @State private var selectedInjuryIndex: Int = 100
    @State private var selectedAttendOfficeIndex: Int = 100
    
    @State private var injuryStatus: String = ""
    @State private var attendOfficeStatus: String = ""
    @Environment(\.presentationMode) var presentationMode
    @Binding var refreshList: Bool // Binding for refreshList
    
    // FocusState
    @FocusState var isFocused: Bool

    var body: some View {
            VStack {
                //notiinfo
                Section {
                    HStack {
                        Text("タイトル: \(String(describing: notification?.notiTitle))")
                        Spacer()
                    }
                    HStack {
                        Text("本文: \(String(describing: notification?.notiBody))")
                        Spacer()
                    }
                }
//                .padding(.horizontal, 20)
                if pageNum == 1 {
/*                    RadioPartsView(
                        selectedInjuryIndex: selectedInjuryIndex,
                        selectedAttendOfficeIndex: selectedAttendOfficeIndex,
                        injuryStatus: injuryStatus,
                        attendOfficeStatus: attendOfficeStatus
                    )
*/
                        VStack {
//                            .padding()
                            // Radio2
                            Section {
                                ForEach(0..<selectInjuryStatus.count, id: \.self, content: { index in
                                    HStack {
                                        Image(systemName: selectedInjuryIndex == index ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                        Text(selectInjuryStatus[index].desc).tag(selectInjuryStatus[index].desc)
                                        Spacer()
                                    }
                                    .frame(height: 20)
                                    .onTapGesture{
                                        selectedInjuryIndex = index
                                        self.injuryStatus = selectInjuryStatus[index].desc
                                        print("injuryStatus: \(self.injuryStatus)")
                                    }
                                })
                                Divider()
                                    .background(.orange)
                                    .padding(.horizontal, 4 )
                                ForEach(0..<selectAttendOfficeStatus.count, id: \.self, content: { index in
                                    HStack {
                                        Image(systemName: selectedAttendOfficeIndex == index ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                        Text(selectAttendOfficeStatus[index].desc).tag(selectAttendOfficeStatus[index].desc)
                                        Spacer()
                                    }
                                    .frame(height: 20)
                                    .onTapGesture{
                                        selectedAttendOfficeIndex = index
                                        self.attendOfficeStatus = selectAttendOfficeStatus[index].desc
                                    }
                                })
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        pageNum = 2
                                    }){
                                        Text("Next")
                                    }
                                }
                            }
//                            .padding()
                            // End radio

                        }
                } else if pageNum == 2 {
                            VStack {
                                Text("メッセージ入力（任意）")
                                Button("キーボードを閉じる") {
                                    self.isFocused = false
                                }
                                TextEditor(text: $message)
                                    .focused(self.$isFocused)
                                    .frame(width: 250, height: 50)
                                    .border(.gray)
                                    .id("TextEditor")
                                Toggle(isOn: $isChecked) {
                                    Text("位置情報を送信する")
                                }
                                .toggleStyle(.checkBox)
                                Button(action: {
                                    Task {
                                        do {
                                            let doc = ReportModel(
                                                notificationId: notification!.notificationId,
                                                uid: viewModel.uid!,
                                                injuryStatus: self.injuryStatus,
                                                attendOfficeStatus: self.attendOfficeStatus,
                                                location: isChecked ? locationClient.address : "",
                                                message: message,
                                                isConfirmed: true
                                            )

                                            try await ReportViewModel.addReport(doc)
                                            print(locationClient.address)
                                            // Return Home
                                            refreshList = true
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                }) {
                                    Text("送信")
                                        .id("SubmitButton")
                                }
                                HStack {
                                    Button(action: {
                                        pageNum = 1
                                    }){
                                        Text("戻る")
                                    }
                                    Spacer()
                                }
                            }
                        .onChange(of: isFocused) { focused in
                            if focused {
                                withAnimation {
                                    sp.scrollTo("SubmitButton", anchor: .top)
                                }
                            }
                        }
                    /*
                     NavigationLink{
                     SecondEnqueteView(
                     viewModel: viewModel,
                     notification: notification,
                     //                        uid: viewModel.uid!,
                     injuryStatus: injuryStatus,
                     attendOfficeStatus: attendOfficeStatus
                     )
                     } label: {
                     HStack {
                     Image(systemName: "arrowshape.right")
                     Text("次へ")
                     }
                     }
                     } */
                }
            }
        .onAppear(perform: {
            Task {
                do {
                    let notifications = try await NotificationViewModel.fetchNotificationbyNotificationId(selectedNotificationId)
                    notification = notifications[0]
                } catch {
                    
                }
            }
        })
    }

struct RadioPartsView: View {
    @State var selectedInjuryIndex: Int = 100
    @State var selectedAttendOfficeIndex: Int = 100
    @State var injuryStatus: String
    @State var attendOfficeStatus: String
//        @State var injuryStatus: String = ""
  //      @State var attendOfficeStatus: String = ""
        
        var body: some View {
            // Radio1
            Section {
                ForEach(0..<selectInjuryStatus.count, id: \.self, content: { index in
                    HStack {
                        Image(systemName: selectedInjuryIndex == index ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        Text(selectInjuryStatus[index].desc).tag(selectInjuryStatus[index].desc)
                        Spacer()
                    }
                    .frame(height: 10)
                    .onTapGesture{
                        selectedInjuryIndex = index
                        self.injuryStatus = selectInjuryStatus[index].desc
                        print("injuryStatus: \(self.injuryStatus)")
                    }
                })
            }
            .padding()
            Divider()
                .background(.orange)
                .padding(.horizontal, 20)
            // Radio2
            Section {
                ForEach(0..<selectAttendOfficeStatus.count, id: \.self, content: { index in
                    HStack {
                        Image(systemName: selectedAttendOfficeIndex == index ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        Text(selectAttendOfficeStatus[index].desc).tag(selectAttendOfficeStatus[index].desc)
                        Spacer()
                    }
                    .frame(height: 10)
                    .onTapGesture{
                        selectedAttendOfficeIndex = index
                        self.attendOfficeStatus = selectAttendOfficeStatus[index].desc
                    }
                })
            }
            .padding()

        }
    }
    
    struct CustomStepTextView: View {
        var text: String
        var body: some View {
            VStack {
                TextView(text: text)
                TextView(text: text)
                TextView(text: text)
                TextView(text: text)
            }
        }
    }
    
    struct IndicatorImageView: View {
        var name: String
        var body: some View {
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .overlay(Image(name)
                        .resizable()
                        .frame(width: 30, height: 30)
                    )
                    .frame(width: 40, height: 40)
            }
        }
    }
    
}
