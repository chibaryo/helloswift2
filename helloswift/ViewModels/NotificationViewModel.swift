//
//  NotificationViewModel.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/10.
//
import FirebaseFirestore
import FirebaseFirestoreSwift

final class NotificationViewModel {
    static let collectionName = "notifications"
    static var firestore = Firestore.firestore()
    
    static func fetchNotifications() async throws -> [NotificationModel] {
        try await firestore.collection(collectionName)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
            .compactMap{ try $0.data(as: NotificationModel.self) }
    }
    
    static func fetchNotificationbyNotificationId (_ notificationId: String) async throws -> [NotificationModel] {
        let querySnapshots = try await firestore.collection("notifications")
            .whereField("notificationId", isEqualTo: notificationId)
            .limit(to: 1)
            .getDocuments()
        
/*        guard let document = querySnapshots.documents.first else {
            return nil
        }
        
        do {
            let notification = try document.data(as: NotificationModel.self)
            return notification
        } catch {
            print("Error decoding notification: \(error)")
            return nil
        } */
        
        let notifications = querySnapshots.documents.compactMap { document in
            try? document.data(as: NotificationModel.self)
        }
        
        return notifications
    }

    static func addNotification(_ document: NotificationModel) async throws {
        let _ = try firestore.collection(collectionName).addDocument(from: document)
    }
    
    static func updateNotification(_ docId: String, document: NotificationModel) throws {
        print("to update docId: \(docId)")
        let _ = try firestore.collection(collectionName).document(docId).setData(from: document)
    }
    
    static func deleteNotification(_ docId: String) async throws {
        let _ = try await firestore.collection(collectionName).document(docId).delete()
    }
}
