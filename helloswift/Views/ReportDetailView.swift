//
//  ReportDetailView.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/05/15.
//

import SwiftUI
import FirebaseFirestore

struct ReportDetailView: View {
    var viewModel: AuthViewModel
    var notification: NotificationModel
    @State var reportsByMe: [ReportModel] = []

    @State private var isEditingInjuryStatus = false
    @State private var isEditingAttendOfficeStatus = false
    @State private var isEditingLocation = false
    @State private var isEditingMessage = false

    @State private var injuryStatus = ""
    @State private var attendOfficeStatus = ""
    @State private var location = ""
    @State private var message = ""

    var body: some View {
        Grid {
            GridRow {
                Text("怪我の有無")
                if isEditingInjuryStatus {
                    TextField("怪我の有無", text: $injuryStatus)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(reportsByMe.first?.injuryStatus ?? "")
                }
                Button(action: {
                    if isEditingInjuryStatus {
                        // check if textbox value is different from the original data
                        if (self.injuryStatus != reportsByMe.first?.injuryStatus) {
                            // if different, then update firestore data
                            updateReportField(field: "injuryStatus", text: self.injuryStatus)
                            // Update UI
                            reportsByMe[0].injuryStatus = self.injuryStatus
                        }
                    } else {
                        self.injuryStatus = reportsByMe.first?.injuryStatus ?? ""
                    }
                    isEditingInjuryStatus.toggle()
                }) {
                    Text(isEditingInjuryStatus ? "保存" : "編集")
                }
            }
            .padding(16)
            .border(Color.gray)
            GridRow {
                Text("出社の可否")
                if isEditingAttendOfficeStatus {
                    TextField("出社の可否", text: $attendOfficeStatus)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(reportsByMe.first?.attendOfficeStatus ?? "")
                }
                Button(action: {
                    if isEditingAttendOfficeStatus {
                        // check if textbox value is different from the original data
                        if (self.attendOfficeStatus != reportsByMe.first?.attendOfficeStatus) {
                            // if different, then update firestore data
                            updateReportField(field: "attendOfficeStatus", text: self.attendOfficeStatus)
                            // Update UI
                            reportsByMe[0].attendOfficeStatus = self.attendOfficeStatus
                        }
                    } else {
                        self.attendOfficeStatus = reportsByMe.first?.attendOfficeStatus ?? ""
                    }
                    isEditingAttendOfficeStatus.toggle()
                }) {
                    Text(isEditingAttendOfficeStatus ? "保存" : "編集")
                }
            }
            .padding(16)
            .border(Color.gray)
            GridRow {
                Text("位置情報")
                Text(reportsByMe.first?.location ?? "N/A")
            }
            .padding(16)
            .border(Color.gray)
            GridRow {
                Text("メッセージ")
                if isEditingMessage {
                    TextField("メッセージ", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(reportsByMe.first?.message ?? "")
                }
                Button(action: {
                    if isEditingMessage {
                        // check if textbox value is different from the original data
                        if (self.message != reportsByMe.first?.message) {
                            // if different, then update firestore data
                            updateReportField(field: "message", text: self.message)
                            // Update UI
                            reportsByMe[0].message = self.message
                        }
                    } else {
                        self.message = reportsByMe.first?.message ?? ""
                    }
                    isEditingMessage.toggle()
                }) {
                    Text(isEditingMessage ? "保存" : "編集")
                }
            }
            .padding(16)
            .border(Color.gray)
        }
        .padding(16)
        .border(Color.gray)
        .onAppear(perform: {
            fetchReport()
        })
    }
    
    private func updateReportField(field: String, text: String) {
        Task {
            do {
                print("_id: \(String(describing: reportsByMe.first?.id))")
                let db = Firestore.firestore()
                let reportRef = db.collection("reports").document(reportsByMe.first!.id!)
                try await reportRef.updateData([
                    field: text
                ])
            } catch {
                print("Error updating document: \(error)")
            }
        }
    }

/*    private func updateReportField(_ keyPath: WritableKeyPath<ReportModel, String?>, with value: String) {
        if let index = reportsByMe.firstIndex(where: { $0.notificationId == notification.notificationId }) {
            reportsByMe[index][keyPath: keyPath] = value
            saveReport()
        }
    } */

    private func saveReport() {
        // Implement saving logic here, e.g., call an API to save the updated report
//        print("Saving report: \(reportsByMe.first ?? ReportModel())")
    }

    private func fetchReport () {
        Task {
            do {
                if (viewModel.uid != nil) {
                    reportsByMe = try await ReportViewModel.fetchReportsByNotificationIdAndUid(
                        notificationId: notification.notificationId,
                        uid: viewModel.uid!
                    )
                    print("reportsByMy: \(reportsByMe)")
                }
                
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
