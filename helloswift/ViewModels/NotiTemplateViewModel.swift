//
//  Token.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotiTemplateModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var notiTemplateId: String // = UUID()
    var notiTitle: String
    var notiBody: String
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case notiTemplateId
        case notiTitle
        case notiBody
        case createdAt
        case updatedAt
    }
    
    init(id: String? = nil, notiTemplateId: String, notiTitle: String, notiBody: String) {
        self.id = id
        self.notiTemplateId = notiTemplateId
        self.notiTitle = notiTitle
        self.notiBody = notiBody
    }
}

final class NotiTemplateViewModel {
    static var firestore = Firestore.firestore()
    
    static func fetchNotiTemplates() async throws -> [NotiTemplateModel] {
        try await firestore.collection("templates")
            .getDocuments()
            .documents
            .compactMap{ try $0.data(as: NotiTemplateModel.self) }
    }
    
    static func addNotiTemplate(_ document: NotiTemplateModel) async throws {
        let _ = try firestore.collection("templates").addDocument(from: document)
    }
    
    static func updateNotiTemplate(_ docId: String, document: NotiTemplateModel) throws {
        print("to update docId: \(docId)")
        let _ = try firestore.collection("templates").document(docId).setData(from: document)
    }
    
    static func deleteNotiTemplate(_ docId: String) async throws {
        let _ = try await firestore.collection("templates").document(docId).delete()
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

extension NotiTemplateModel: Equatable {
    static func == (lhs: NotiTemplateModel, rhs: NotiTemplateModel) -> Bool {
        // Implement your equality logic here
        return lhs.id == rhs.id // Assuming `id` is unique for each `NotiTemplateModel`
    }
}
