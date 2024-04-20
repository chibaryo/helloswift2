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
            .compactMap{ try $0.data(as: UserModel.self) }
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
    
    static func addUser(_ uid: String, document: UserModel) async throws {
        let _ = try firestore.collection("users").document(uid).setData(from: document)
//        let _ = try firestore.collection("users").addDocument(from: document)
    }
    
    
    static func updateUser(_ uid: String, document: UserModel) throws {
        let _ = try firestore.collection("users").document(uid).setData(from: document)
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
