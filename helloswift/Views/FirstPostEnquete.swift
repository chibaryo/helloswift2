import SwiftUI
import Combine
import CoreLocationUI

struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                self.cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                    .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
                    .compactMap { notification in
                        notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    }
                    .map { $0.height }
                    .assign(to: \.keyboardHeight, on: self)
            }
            .onDisappear {
                self.cancellable?.cancel()
            }
    }
}

extension View {
    func keyboardAware() -> some View {
        self.modifier(KeyboardAwareModifier())
    }
}
struct CustomCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(configuration.isOn ? .white : .gray)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
let rselectInjuryStatus: [RadioGroup] = [
    RadioGroup(index: -1, desc: "選択してください"),
    RadioGroup(index: 0, desc: "無事"),
    RadioGroup(index: 1, desc: "怪我"),
    RadioGroup(index: 2, desc: "その他")
]
let rselectAttendOfficeStatus: [RadioGroup] = [
    RadioGroup(index: -1, desc: "選択してください"),
    RadioGroup(index: 0, desc: "出社可"),
    RadioGroup(index: 1, desc: "出社不可"),
    RadioGroup(index: 2, desc: "出社済")
]

struct FirstPostEnquete: View {
    @EnvironmentObject var firstPostEnqueteViewModel: FirstPostEnqueteViewModel
    var authViewModel: AuthViewModel
    @State private var isChecked: Bool = false
    @StateObject var locationClient = LocationClient()
    
    
    @State private var pageNum: Int = 1
    @State private var rselectedInjuryIndex: Int = -1
    @State private var rselectedAttendOfficeIndex: Int = -1
    
    @State private var injuryStatus: String = ""
    @State private var attendOfficeStatus: String = ""
    @State private var rmessage: String = ""
    @State private var showValidationMessage: Bool = false
    //
    @State private var isLocationChecked: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    // FocusState
    @FocusState var isKbdFocused: Bool
    @Binding var refreshList: Bool // Binding for refreshList
    @State private var isRequestingLocation = false
    
    var body: some View {
        ZStack {
            // Background image
            Color.cyan.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("通知に回答する")
                    .font(.title2)
                    .foregroundColor(.black)
                
                Spacer()
                if let notificationId = firstPostEnqueteViewModel.notificationId {
                    Section {
                        HStack {
                            Text("タイトル")
                                .foregroundColor(.white)
                            Spacer()
                            Text(firstPostEnqueteViewModel.notiTitle ?? "")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        
                        HStack {
                            Text("本文")
                                .foregroundColor(.white)
                            Spacer()
                            Text(firstPostEnqueteViewModel.notiBody ?? "")
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    }
                    
                    // Confirmation
                    if firstPostEnqueteViewModel.notiType == "confirmation" {
                        Section {
                            Toggle(isOn: $isChecked) {
                                Text("確認しました")
                                    .foregroundColor(.white)
                            }
                            .toggleStyle(CustomCheckboxStyle())
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                            
                            Spacer()
                            HStack {
                                Button(action: {
                                    Task {
                                        do {
                                            let doc = ReportModel(
                                                notificationId: notificationId,
                                                uid: authViewModel.uid!,
                                                injuryStatus: "",
                                                attendOfficeStatus: "",
                                                location: "",
                                                message: "",
                                                isConfirmed: isChecked ? true : false
                                            )
                                            
                                            try await ReportViewModel.addReport(doc)
                                            presentationMode.wrappedValue.dismiss()
                                            firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
                                        }
                                    }
                                }) {
                                    Text("送信")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity)
                        }
                        // Enquete
                    } else if firstPostEnqueteViewModel.notiType == "enquete" {
                        Section {
                            // injuryStatus
                            if showValidationMessage {
                                Text("please select one")
                                    .foregroundColor(.red)
                                    .padding(.bottom, 5)
                            }
                            // Sel 1
                            HStack {
                                Text("怪我の有無")
                                    .fixedSize()
                                Spacer()
                                Picker("選択してください", selection: $rselectedInjuryIndex) {
                                    ForEach(rselectInjuryStatus, id: \.index) { status in
                                        Text(status.desc).tag(status.index)
                                    }
                                }
                                .onChange(of: rselectedInjuryIndex) { newValue in
                                    if let selectedStatus = rselectInjuryStatus.first(where: { $0.index == newValue }) {
                                        self.injuryStatus = selectedStatus.desc
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.5)) // Set the entire row to the same background color
                            .cornerRadius(10)
                            //                            .padding()
                            //                            .frame(maxWidth: .infinity) // Extend picker box to full width
                            /*                            ForEach(0..<rselectInjuryStatus.count, id: \.self, content: { index in
                             HStack {
                             Image(systemName: rselectedInjuryIndex == index ? "checkmark.circle.fill" : "circle")
                             .foregroundColor(.blue)
                             Text(rselectInjuryStatus[index].desc).tag(rselectInjuryStatus[index].desc)
                             Spacer()
                             }
                             .frame(height: 20)
                             .onTapGesture{
                             rselectedInjuryIndex = index
                             self.injuryStatus = rselectInjuryStatus[index].desc
                             }
                             }) */
                            /* sel 2 */
                            HStack {
                                Text("出社の可否")
                                    .fixedSize()
                                Spacer()
                                Picker("選択してください", selection: $rselectedAttendOfficeIndex) {
                                    ForEach(rselectAttendOfficeStatus, id: \.index) { status in
                                        Text(status.desc).tag(status.index)
                                    }
                                }
                                .onChange(of: rselectedAttendOfficeIndex) { newValue in
                                    if let selectedStatus = rselectAttendOfficeStatus.first(where: { $0.index == newValue }) {
                                        self.attendOfficeStatus = selectedStatus.desc
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.5)) // Set the entire row background color here
                            .cornerRadius(10)

                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Button("キーボードを閉じる") {
                                        self.isKbdFocused = false
                                    }
                                    Text("メッセージ入力（任意）")
                                    TextEditor(text: $rmessage)
                                        .focused(self.$isKbdFocused)
                                        .frame(width: 250, height: 100)
                                        .border(.gray)
                                        .id("TextEditor")
                                }
                            }
                            HStack {
                                // loc
                                LocationButton(.currentLocation) {
                                    locationClient.requestLocation()
                                }
                                .symbolVariant(.fill)
                                .labelStyle(.iconOnly)
                                .foregroundColor(.white)
                                .cornerRadius(20)
    //                            .font(.system(size: 12))
                                //
                                Toggle(isOn: $isLocationChecked) {
                                    Text("位置情報を送信する")
                                        .foregroundColor(.white)
                                }
                                .toggleStyle(CustomCheckboxStyle())
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(10)
                                .onChange(of: isLocationChecked) { newValue in
                                    print("toggled to: \(isLocationChecked)")
                                    if isLocationChecked && locationClient.address.isEmpty == true {
                                        print("You must first press locationButton!")
                                        isRequestingLocation = true
                                        // Toggle off the checkbutton
                                        isLocationChecked = false
                                    } else if isLocationChecked && locationClient.address.isEmpty == false {
                                        isRequestingLocation = false
                                    }
                                }
                            }
                            //
                            if let location = locationClient.location {
                                Text("現在地: \(locationClient.address)")
                            }
                            if isRequestingLocation {
                                VStack {
                                    Text("位置情報取得ボタンを押してから")
                                        .foregroundColor(Color.red)
                                        .multilineTextAlignment(.leading)
                                    Text("チェックをオンにしてください")
                                        .foregroundColor(Color.red)
                                        .multilineTextAlignment(.leading)
                                }
                            }

                            Button(action: {
                                if rselectedInjuryIndex == -1 || rselectedAttendOfficeIndex == -1 {
                                    showValidationMessage = true
                                } else {
                                    showValidationMessage = false
                                    //
                                    Task {
                                        do {
                                            print("address: \(locationClient.address)")
                                            let doc = ReportModel(
                                                                                            notificationId: notificationId,
                                                                                            uid: authViewModel.uid!,
                                                                                            injuryStatus: self.injuryStatus,
                                                                                            attendOfficeStatus: self.attendOfficeStatus,
                                                                                            location: isLocationChecked ? locationClient.address : "",
                                                                                            message: self.rmessage,
                                                                                            isConfirmed: true
                                            )
                                            try await ReportViewModel.addReport(doc)
                                            refreshList = true
                                            presentationMode.wrappedValue.dismiss()
                                            firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
                                            // Clear form
                                            rselectedInjuryIndex = -1
                                            rselectedAttendOfficeIndex = -1
                                            rmessage = ""
                                        }
                                    }
/*                                    Task {
                                        do {
                                            let doc = ReportModel(
                                                                                            notificationId: notificationId,
                                                                                            uid: authViewModel.uid!,
                                                                                            injuryStatus: self.injuryStatus,
                                                                                            attendOfficeStatus: self.attendOfficeStatus,
                                                                                            location: isLocationChecked ? locationClient.address : "",
                                                                                            message: self.rmessage,
                                                                                            isConfirmed: true
                                            )
                                            try await ReportViewModel.addReport(doc)
                                            refreshList = true
                                            presentationMode.wrappedValue.dismiss()
                                            firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
                                        }
                                    } */
                                }
                            }) {
                                    Text("送信")
                                        .id("SubmitButton")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(rselectedInjuryIndex == -1 || rselectedAttendOfficeIndex == -1 ? Color.gray : Color.blue) // || refreshList
                                    //                                    .background(Color.blue)
                                        .cornerRadius(10)
                            }
                            .disabled(rselectedInjuryIndex == -1 || rselectedAttendOfficeIndex == -1 || isRequestingLocation)
                            .onChange(of: locationClient.address) { newValue in
                                print("goooo!!!")
/*                                if isLocationChecked && locationClient.address.isEmpty == false {
                                    isRequestingLocation = false
                                    // Submit data
                                    print("Submit data!")
                                } */
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .keyboardAware() // Apply the custom modifier here
        .onDisappear(perform: {
            firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
        })
    }
    
    private func submitReport(with location: String) {
        Task {
            if let notificationId = firstPostEnqueteViewModel.notificationId {
                do {
                    print("### locationClient ### : \(location)")
                    let doc = ReportModel(
                        notificationId: notificationId,
                        uid: authViewModel.uid!,
                        injuryStatus: self.injuryStatus,
                        attendOfficeStatus: self.attendOfficeStatus,
                        location: location,
                        message: self.rmessage,
                        isConfirmed: true
                    )
                    
                    try await ReportViewModel.addReport(doc)
                    
                    refreshList = true
                    presentationMode.wrappedValue.dismiss()
                    firstPostEnqueteViewModel.isActiveFirstPostEnqueteView = false
                } catch {
                    // Handle error
                }
            }
        }
    }
    
}
