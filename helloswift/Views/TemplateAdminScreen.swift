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

struct TemplateAdminScreen: View {
    @State var notiTemplates: [NotiTemplateModel] = []
    @State var isLoading: Bool = false

    @State private var currentDocId: String = ""
    @State private var presentEditAlert: Bool = false
    @State private var presentDelAlert: Bool = false
    @State private var inputNotiTitle: String = ""
    @State private var inputNotiBody: String = ""
    // Firestore listener
    @State private var listener: ListenerRegistration?

    @AppStorage(wrappedValue: 1, "pageSelection") var pageSelection
    @State var isActive: Bool = false
    var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(notiTemplates, id: \.id) { e in
                        VStack(alignment: .leading) {
                            HStack {
                                if let createdAt = e.createdAt {
                                    Text("\(createdAt.dateValue(), format: .dateTime.month(.defaultDigits).day()) \(e.notiTitle)")
                                } else {
                                    Text("Date unknown: \(e.notiTitle)")
                                }
                                Spacer()
                                //Text(e.notiBody).foregroundStyle(.secondary)
                                //Spacer()
                                    Button(action: {
                                        self.currentDocId = e.id!
                                        self.inputNotiTitle = e.notiTitle
                                        self.inputNotiBody = e.notiBody
                                        presentEditAlert = true
                                    }){
                                        Image(systemName: "square.and.pencil")
                                    }
                                    .buttonStyle(.borderless)
                                    .alert("テンプレート編集", isPresented: $presentEditAlert) {
                                        TextField("タイトル", text: $inputNotiTitle)
                                        TextField("本文", text: $inputNotiBody)

                                        Button("保存", action: {
                                            Task {
                                                do {
                                                    //presentEditAlert = false
                                                    let doc = NotiTemplateModel(
                                                        notiTemplateId: UUID().uuidString,
                                                        notiTitle: inputNotiTitle,
                                                        notiBody: inputNotiBody
                                                    )
                                                    try NotiTemplateViewModel.updateNotiTemplate(currentDocId, document: doc)
                                                    // Clear form
                                                    self.inputNotiTitle = ""
                                                    self.inputNotiBody = ""
                                                }
                                            }
                                        })
                                        Button("キャンセル", action: {})
                                    } message: {
                                        Text("保存するテンプレートを登録してください")
                                    }
                                    Button(action: {
                                        self.currentDocId = e.id!
                                        self.inputNotiTitle = e.notiTitle
                                        self.inputNotiBody = e.notiBody
                                        presentDelAlert = true
                                    }){
                                            Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                    .alert("テンプレート削除", isPresented: $presentDelAlert) {
                                        TextField("タイトル", text: $inputNotiTitle)
                                        TextField("本文", text: $inputNotiBody)

                                        Button("削除", action: {
                                            Task {
                                                do {
                                                    //presentDelAlert = false
                                                    try await NotiTemplateViewModel.deleteNotiTemplate(currentDocId)
                                                    // Clear form
                                                    self.inputNotiTitle = ""
                                                    self.inputNotiBody = ""
                                                }
                                            }
                                        })
                                        Button("キャンセル", action: {})
                                    } message: {
                                        Text("このテンプレートを削除しますか？")
                                    }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.bottom, 1)
                        }
                    }
                }
                .navigationTitle("\(notiTemplates.count) テンプレート管理")
                .toolbar {
                    ToolbarItem{
                        Button(action: {
                            presentEditAlert = true
                        }){
                            Label("Add enquete", systemImage: "plus")
                        }
                        .alert("テンプレート登録", isPresented: $presentEditAlert, actions: {
                            TextField("タイトル", text: $inputNotiTitle)
                            TextField("本文", text: $inputNotiBody)

                            Button("保存", action: {
                                Task {
                                    do {
                                        let doc = NotiTemplateModel(
                                            notiTemplateId: UUID().uuidString,
                                            notiTitle: inputNotiTitle,
                                            notiBody: inputNotiBody
                                        )
                                        try await NotiTemplateViewModel.addNotiTemplate(doc)
                                        // Clear form
                                        self.inputNotiTitle = ""
                                        self.inputNotiBody = ""
                                    }
                                }
                            })
                            Button("キャンセル", action: {})
                        }, message: {
                            Text("保存するテンプレートを登録してください")
                        })
                    }
                }
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
                notiTemplates = try await NotiTemplateViewModel.fetchNotiTemplates()
                isLoading.toggle()
                
                debugPrint(notiTemplates)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }

    private func listenForUpdates() {
            // Set up Firestore listener to observe changes in the collection
            listener = Firestore.firestore().collection("templates")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        if let error = error {
                            print("Error fetching snapshots: \(error)")
                        }
                        return
                    }
                    
                    // Parse snapshot data into NotiTemplateModel objects
                    do {
                        let notiTemplates = try snapshot.documents.compactMap { try $0.data(as: NotiTemplateModel.self) }
                        self.notiTemplates = notiTemplates
                    } catch {
                        print("Error decoding snapshot: \(error)")
                    }
                }
        }
}
