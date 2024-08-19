//
//  Token.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/08.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ReportViewModel {
    static var firestore = Firestore.firestore()
    
    static func fetchReports() async throws -> [ReportModel] {
        try await firestore.collection("reports")
            .getDocuments()
            .documents
            .compactMap{ try $0.data(as: ReportModel.self) }
    }
    
    static func fetchReportsByUid (_ uid: String) async throws -> [ReportModel] {
        let querySnapshots = try await firestore.collection("reports")
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
        
        let reports = querySnapshots.documents.compactMap { document in
            try? document.data(as: ReportModel.self)
        }
        
        return reports
    }
    
    static func deleteReportsByUid(_ uid: String) async throws {
        let querySnapshots = try await firestore.collection("reports")
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
        
        for document in querySnapshots.documents {
            try await document.reference.delete()
        }
    }

    static func fetchReportsByNotificationId (_ notificationId: String) async throws -> [ReportModel] {
        let querySnapshots = try await firestore.collection("reports")
            .whereField("notificationId", isEqualTo: notificationId)
            .getDocuments()
        
        let reports = querySnapshots.documents.compactMap { document in
            try? document.data(as: ReportModel.self)
        }
        
        return reports
    }

    static func fetchReportsByNotificationIdAndUid (notificationId: String, uid: String) async throws -> [ReportModel] {
        let querySnapshots = try await firestore.collection("reports")
            .whereField("notificationId", isEqualTo: notificationId)
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
        
        let reports = querySnapshots.documents.compactMap { document in
            try? document.data(as: ReportModel.self)
        }
        
        return reports
    }

    static func addReport(_ document: ReportModel) async throws {
        let _ = try firestore.collection("reports").addDocument(from: document)
    }
    
    static func updateReport(_ docId: String, document: ReportModel) throws {
        print("to update docId: \(docId)")
        let _ = try firestore.collection("reports").document(docId).setData(from: document)
    }
    
    static func deleteReport(_ docId: String) async throws {
        let _ = try await firestore.collection("reports").document(docId).delete()
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
