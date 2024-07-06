//
//  HomeView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Define a DateFormatter extension or utility
extension DateFormatter {
    static let customFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
}

struct NotiAdminScreen: View {
    @State var notifications: [NotificationModel] = []
    @State var notiTemplates: [NotiTemplateModel] = []
    @State var isLoading: Bool = false
    
    @State private var currentDocId: String = ""
    @State private var presentEditAlert: Bool = false
    @State private var presentDelAlert: Bool = false
    @State private var inputNotiTitle: String = ""
    @State private var inputNotiBody: String = ""
    // Firestore listener
    @State private var listener: ListenerRegistration?
    // Dropdown
    @State private var selection = "notice_all"
    // Dropdown 2
    @State private var notiTypeSelection = "enquete"

    //    @State private var templateSel = ""
    @State private var templateSel: String = ""
    @State private var isShowingPicker = false
    @Environment(\.dismiss) var dismiss
    
    // Pagination
    @State private var totalItems: Double = 0
    private var step:Double = 5
    @State private var totalPages: Int = 0
    @State private var currentPage: Int = 1
    //
    @State private var startFrom: Int = 0
    @State private var endAt: Int = 0
    //
    @State private var limitedArray: [NotificationModel] = []
    
    struct Topic: Identifiable, Hashable {
        var tagname: String
        var desc: String
        var id: String { self.tagname }
    }
    
    private let topics: [Topic] = [
        Topic(tagname: "notice_all", desc: "全体通知"),
        Topic(tagname: "notice_nagoya", desc: "名古屋"),
        Topic(tagname: "notice_osaka", desc: "大阪"),
        Topic(tagname: "notice_tokyo", desc: "東京"),
        Topic(tagname: "test_2024", desc: "Test_2024"),
    ]

    struct NotiType: Identifiable, Hashable {
        var notiTypeName: String
        var desc: String
        var id: String { self.notiTypeName }
    }
    
    private let notiTypes: [NotiType] = [
        NotiType(notiTypeName: "enquete", desc: "アンケート"),
        NotiType(notiTypeName: "confirmation", desc: "確認のみ"),
    ]
    
    public struct NotificationPayload: Codable {
        public var title: String
        public var body: String
        public var topic: String
        public var type: String
        public var data: NotificationData
        
        public struct NotificationData: Codable {
            public var notificationId: String
            public var type: String
        }
        
        func jsonData() -> Data {
            return try! JSONEncoder().encode(self)
        }
        
        func jsonStr() -> String {
            let data = jsonData()
            return String(data: data, encoding: .utf8)!
        }
    }
    
    @AppStorage(wrappedValue: 1, "pageSelection") var pageSelection
    @State var isActive: Bool = false
    var viewModel: AuthViewModel

    internal init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        ForEach(sortedNotifications, id: \.notificationId) { e in
                            VStack(alignment: .leading) {
                                NavigationLink {
                                    NotiDetailView(
                                        viewModel: viewModel,
                                        notificationId: e.notificationId
                                    )
                                } label: {
                                    HStack {
                                        if let createdAt = e.createdAt {
                                            Text("[\(DateFormatter.customFormat.string(from: createdAt.dateValue()))] \(e.notiTitle) \(e.notiTitle)")
                                        } else {
                                            Text("Date unknown: \(e.notiTitle)")
                                        }
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.bottom, 1)
                                }
                            }
                        }
                    }
                    /* footer: {
                        HStack {
                            Button(action: {
                                if (self.currentPage > 1) {
                                    self.currentPage -= 1
                                    print("decremented: currentPage = \(self.currentPage)")
                                    
                                    calcPagination()
                                }
                            }) {
                                Text("Prev")
                            }
                            .buttonStyle(.borderless)
                            Spacer()
                            Button(action: {
                                if (self.currentPage < self.totalPages) {
                                    self.currentPage += 1
                                    print("incremented.")
                                    
                                    calcPagination()
                                }
                            }) {
                                Text("Next")
                            }
                            .buttonStyle(.borderless)
                        }
                    } */
                }
                .navigationTitle("\(notifications.count) 通知管理")
                .toolbar {
                    ToolbarItem{
                        Button(action: {
                            //presentEditAlert = true
                            isShowingPicker.toggle()
                        }){
                            Label("Add enquete", systemImage: "plus")
                        }
                        .sheet(isPresented: $isShowingPicker, onDismiss: {
                            // Clear
                            self.selection = "notice_all"
                            self.templateSel = ""
                            self.inputNotiTitle = ""
                            self.inputNotiBody = ""
                            self.notiTypeSelection = "enquete"
                        }) {
                            VStack {
                                Text("送信先：")
                                Picker(selection: $selection, label: Text("Select a topic")) {
                                    ForEach(topics, id: \.self.tagname) {
                                        Text($0.desc)
                                    }
                                }
                                //Spacer()
                                // TemplateSel
                                Picker(selection: $templateSel, label: Text("Select a template")) {
                                    Text("テンプレート候補").tag(nil as String?)
                                    ForEach(notiTemplates, id: \.self.notiTemplateId) { //template in
                                        Text($0.notiTitle).tag(Optional($0.notiTemplateId))
                                    }
                                }
                                .onChange(of: templateSel) { newValue in
                                    print("newValue: \(newValue)")
                                    // find one
                                    if let template = notiTemplates.first(where: { $0.notiTemplateId == newValue }) {
                                        // Found the template with the specified ID
                                        self.inputNotiTitle = template.notiTitle
                                        self.inputNotiBody = template.notiBody
                                        //                                        print("Found template: \(template.notiTitle)")
                                        //                                      print("Found template: \(template.notiBody)")
                                    } else {
                                        // Template with the specified ID not found
                                        print("Template not found")
                                    }
                                }
                                //
                                Picker(selection: $notiTypeSelection, label: Text("Select a type")) {
                                    ForEach(notiTypes, id: \.self.notiTypeName) {
                                        Text($0.desc)
                                    }
                                }
                                //
                                TextField("タイトル", text: $inputNotiTitle)
                                TextField("本文", text: $inputNotiBody)
                                
                                HStack {
                                    Button(action: {
                                        // Gen UUID
                                        let uuid = UUID()
                                        debugPrint("now UUID is : \(uuid.uuidString)")

                                        // Send message via server
                                        let semaphore = DispatchSemaphore(value: 0)
                                        let notificationPayload = NotificationPayload(
                                            title: inputNotiTitle,
                                            body: inputNotiBody,
                                            topic: selection,
                                            type: notiTypeSelection,
                                            data: NotificationPayload.NotificationData(
                                                notificationId: uuid.uuidString,
                                                type: notiTypeSelection
                                            )
                                        )
                                        let postData = notificationPayload.jsonData()
                                        
                                        var request = URLRequest(url: URL(string: "https://fcm-noti-ios.vercel.app/api/sendToTopic")!, timeoutInterval: Double.infinity)
                                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                        request.httpMethod = "POST"
                                        request.httpBody = postData
                                        
                                        // task
                                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                            guard let data = data else {
                                                print(String(describing: error))
                                                semaphore.signal()
                                                return
                                            }
                                            print(String(data: data, encoding: .utf8)!)
                                            semaphore.signal()
                                        }
                                        
                                        task.resume()
                                        semaphore.wait()
                                        
                                        // Write notification data to Firestore
                                        Task {
                                            do {
                                                let doc = NotificationModel(
                                                    notificationId: uuid.uuidString,
                                                    notiTitle: inputNotiTitle,
                                                    notiBody: inputNotiBody,
                                                    notiTopic: selection,
                                                    notiType: notiTypeSelection
                                                )
                                                try await NotificationViewModel.addNotification(doc)
                                                // Clear form
                                                self.inputNotiTitle = ""
                                                self.inputNotiBody = ""
                                            }
                                        }
                                        
                                        self.isShowingPicker = false

                                        // Update
                                        fetch()
                                        listenForUpdates()

                                    }) {
                                        Text("送信")
                                    }
                                    .buttonStyle(.borderless)
                                    Button(action: {
                                        self.isShowingPicker = false
                                    }) {
                                        Text("キャンセル").foregroundColor(.red)
                                    }
                                    .buttonStyle(.borderless)
                                }
                                
                            }
                            .presentationDetents([.medium])
                            .padding()
                        }
                        
                        /* .alert("通知送信", isPresented: $presentEditAlert, actions: {
                         TextField("タイトル", text: $inputNotiTitle)
                         TextField("本文", text: $inputNotiBody)
                         Picker("select a ", selection: $selection) {
                         ForEach(topics, id: \.self.tagname) {
                         Text($0.desc)
                         }
                         }
                         .pickerStyle(.menu)
                         
                         Button("送信", action: {
                         Task {
                         do {
                         let doc = NotificationModel(
                         notiTitle: inputNotiTitle,
                         notiBody: inputNotiBody
                         )
                         try await NotificationViewModel.addNotification(doc)
                         // Clear form
                         self.inputNotiTitle = ""
                         self.inputNotiBody = ""
                         }
                         }
                         })
                         Button("キャンセル", action: {})
                         }, message: {
                         Text("noiti登録してください")
                         }) */
                    }
                }
            }
        }
        .task {
            do {
                let count = try await Firestore.firestore()
                    .collection("reports")
                    .whereField("notificationId", isEqualTo: "903A33FC-20D2-4F4B-8294-9797E5DABBAB")
                    .count
                    .getAggregation(source: .server)
                    .count
                    .intValue
                print("#### trying.... ####")
                print("count: \(count)")
            } catch {
                print("error: \(error)")
            }
            
        }
        .onAppear(perform: {
            fetch()
            listenForUpdates()
        })
        .onDisappear(perform: {
            // Stop listening for updates when the view disappears
            listener?.remove()
        })
    }
    
    private func fetch () {
        Task {
            do {
                isLoading.toggle()
                notifications = try await NotificationViewModel.fetchNotifications()
                notiTemplates = try await NotiTemplateViewModel.fetchNotiTemplates()
                isLoading.toggle()
                
                // Set default limitedArray
                self.totalItems = Double(notifications.count)
                print("totalItems: \(self.totalItems)")
                self.totalPages = Int(ceil(self.totalItems / step))
                print("totalPages: \(self.totalPages)")
                calcPagination()

                //                debugPrint(notifications)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func listenForUpdates() {
        // Set up Firestore listener to observe changes in the collection
        listener = Firestore.firestore().collection("notifications")
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    if let error = error {
                        print("Error fetching snapshots: \(error)")
                    }
                    return
                }
                
                // Parse snapshot data into NotiTemplateModel objects
                do {
                    let notifications = try snapshot.documents.compactMap { try $0.data(as: NotificationModel.self) }
                    self.notifications = notifications
                } catch {
                    print("Error decoding snapshot: \(error)")
                }
            }
    }

    private var sortedNotifications: [NotificationModel] {
        notifications.sorted(by: { $0.createdAt?.dateValue() ?? Date.distantPast > $1.createdAt?.dateValue() ?? Date.distantPast })
    }

    private func calcPagination () {
        self.startFrom = Int(step) * (self.currentPage - 1) + 1
        if (totalPages == currentPage) {
            self.endAt = Int(totalItems)
        } else {
            self.endAt = self.currentPage * Int(step)
        }
       
        print("startFrom: \(self.startFrom)")
        print("endAt: \(self.endAt)")
        self.limitedArray = Array(notifications[(self.startFrom - 1)..<self.endAt])
        //print("limitedArray: \(self.limitedArray)")
    }

}

