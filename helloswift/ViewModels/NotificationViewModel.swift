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
            .getDocuments()
            .documents
            .compactMap{ try $0.data(as: NotificationModel.self) }
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
