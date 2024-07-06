import SwiftUI
import FirebaseFirestore

struct ReportDetailView: View {
    var viewModel: AuthViewModel
    var notification: NotificationModel
    @State var reportsByMe: [ReportModel] = []

    @State private var isEditingInjuryStatus = false
    @State private var isEditingAttendOfficeStatus = false
    @State private var isEditingMessage = false

    @State private var injuryStatus = ""
    @State private var attendOfficeStatus = ""
    @State private var message = ""

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                ReportDetailRow(label: "タイトル", value: notification.notiTitle)
                ReportDetailRow(label: "本文", value: notification.notiBody)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 10)
            .padding()

            VStack(spacing: 16) {
                EditableReportDetailRow(
                    label: "怪我の有無",
                    value: $injuryStatus,
                    isEditing: $isEditingInjuryStatus,
                    originalValue: reportsByMe.first?.injuryStatus,
                    saveAction: { updateReportField(field: "injuryStatus", text: injuryStatus) }
                )

                EditableReportDetailRow(
                    label: "出社の可否",
                    value: $attendOfficeStatus,
                    isEditing: $isEditingAttendOfficeStatus,
                    originalValue: reportsByMe.first?.attendOfficeStatus,
                    saveAction: { updateReportField(field: "attendOfficeStatus", text: attendOfficeStatus) }
                )

                ReportDetailRow(label: "位置情報", value: reportsByMe.first?.location ?? "N/A")

                EditableReportDetailRow(
                    label: "メッセージ",
                    value: $message,
                    isEditing: $isEditingMessage,
                    originalValue: reportsByMe.first?.message,
                    saveAction: { updateReportField(field: "message", text: message) }
                )
                ReportDetailRow(label: "確認しました", value: (reportsByMe.first?.isConfirmed ?? false) ? "はい" : "いいえ")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 10)
            .padding()
        }
        .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
        .onAppear(perform: fetchReport)
    }
    
    private func updateReportField(field: String, text: String) {
        Task {
            do {
                print("_id: \(String(describing: reportsByMe.first?.id))")
                let db = Firestore.firestore()
                let reportRef = db.collection("reports").document(reportsByMe.first!.id!)
                try await reportRef.updateData([field: text])
                // Update UI
                if field == "injuryStatus" {
                    reportsByMe[0].injuryStatus = text
                } else if field == "attendOfficeStatus" {
                    reportsByMe[0].attendOfficeStatus = text
                } else if field == "message" {
                    reportsByMe[0].message = text
                }
            } catch {
                print("Error updating document: \(error)")
            }
        }
    }

    private func fetchReport() {
        Task {
            do {
                if let uid = viewModel.uid {
                    reportsByMe = try await ReportViewModel.fetchReportsByNotificationIdAndUid(
                        notificationId: notification.notificationId,
                        uid: uid
                    )
                    print("reportsByMy: \(reportsByMe)")
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

struct ReportDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct EditableReportDetailRow: View {
    let label: String
    @Binding var value: String
    @Binding var isEditing: Bool
    let originalValue: String?
    let saveAction: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            if isEditing {
                TextField(label, text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(originalValue ?? "")
            }
            Button(action: {
                if isEditing {
                    saveAction()
                } else {
                    value = originalValue ?? ""
                }
                isEditing.toggle()
            }) {
                Text(isEditing ? "保存" : "編集")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
