//
//  Token.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


final class UserViewModel {
    static var firestore = Firestore.firestore()
    
    static func fetchUsers() async throws -> [UserModel] {
        try await firestore.collection("users")
            .getDocuments()
            .documents
            .compactMap{ try? $0.data(as: UserModel.self) }
    }
    
    static func revisedFetchUserByUid(documentId: String) async throws -> UserModel? {
        print("rev documentId: \(documentId)")
        let userRef = firestore.collection("users").document(documentId)
        
        do {
            let document = try await userRef.getDocument()
            let user = try document.data(as: UserModel.self)
            return user
        } catch {
            throw error
        }
    }
    
    static func fetchUserByUid(documentId: String) async throws -> UserModel? {
        print("documentId: \(documentId)")

        let querySnapshot = try await firestore.collection("users")
            .document(documentId)
            .getDocument(as: UserModel.self)

/*        guard let document = querySnapshot.documents.first else {
             // If no document is found, return nil
             return nil
         }
  */
//         let user = try document.data(as: UserModel.self)
        print("querySnapshot: \(querySnapshot)")
         return querySnapshot
    }

    static func fetchUsersByLocation(officeLocation: String) async throws -> [UserModel] {
        let querySnapshots = try await firestore.collection("users")
            .whereField("officeLocation", isEqualTo: officeLocation)
            .getDocuments()

        let users = querySnapshots.documents.compactMap { document in
            try? document.data(as: UserModel.self)
        }
        
        print("fetched users: \(users)")
        return users
    }

    static func addUser(_ uid: String, document: UserModel) async throws {
        let _ = try firestore.collection("users").document(uid).setData(from: document)
//        let _ = try firestore.collection("users").addDocument(from: document)
    }
    
    
    static func updateUser(_ uid: String, document: UserModel) throws {
        let _ = try firestore.collection("users").document(uid).setData(from: document)
    }
    
    static func deleteUser(_ uid: String) async throws {
        let _ = try await firestore.collection("users").document(uid).delete()
    }
    
    static func fetchUsersWhoDidNotRespond(notificationId: String) async throws -> [UserModel] {
        // Fetch all users
        let allUsersQuerySnapshot = try await firestore.collection("users").getDocuments()
        let allUsers = allUsersQuerySnapshot.documents.compactMap { try? $0.data(as: UserModel.self) }

        // Fetch reports related to the notification
        let reportsQuerySnapshot = try await firestore.collection("reports")
            .whereField("notificationId", isEqualTo: notificationId)
            .getDocuments()
        let respondedUserIds = Set(reportsQuerySnapshot.documents.compactMap { $0["uid"] as? String })
//        print("++ respondedUserIds ++: \(respondedUserIds)")

        // Filter users who did not respond
        let nonRespondedUsers = allUsers.filter { !respondedUserIds.contains($0.uid) }
//        print("+++ nonRespondedUsers +++: \(nonRespondedUsers)")

        return nonRespondedUsers
    }
}


/*import Foundation
import FirebaseFirestore


final class NotiTemplateViewModel {
    static var firestore = Firestore.firestore()
    
    static func fetchNotiTemplates() async throws -> [NotiTemplateElement] {
        try await firestore.collection("notitemplates")
            .getDocuments()
            .documents
            .compactMap{ try $0.data(as: NotiTemplateElement.self) }
    }
    
    static func addNotiTemplate(_ document: NotiTemplateElement) async throws {
        let _ = try firestore.collection("notitemplates").addDocument(from: document)
    }
}


*/
