//
//  Token.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBPlatformInfoModel: Identifiable, Codable {
    @DocumentID var id: String?
//    var udid: String
    var systemName: String
    var osVersion: String
//    var osVersion: String
//    var localizedModel: String
//    var productName: String
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case systemName
        case osVersion
        case createdAt
        case updatedAt
    }
    
    init(id: String? = nil, systemName: String, osVersion: String) {
        self.id = id
        self.systemName = systemName
        self.osVersion = osVersion
    }
}

final class APIClient {
    static var firestore = Firestore.firestore()
    
    static func fetchPlatformInfo() async throws -> [DBPlatformInfoModel] {
        try await firestore.collection("tokens")
            .getDocuments()
            .documents
            .compactMap{ try $0.data(as: DBPlatformInfoModel.self) }
    }
    
    static func addPlatformInfo(_ platformInfo: DBPlatformInfoModel) async throws {
        let _ = try firestore.collection("tokens").addDocument(from: platformInfo)
    }
}
