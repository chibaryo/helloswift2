//
//  NotiTemplateElement.swift
//  helloswift
//
//  Created by Ryo Chiba on 2024/04/10.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotiTemplateElement: Identifiable, Codable {
    @DocumentID var id: String?
    //    var udid: String
    var notiTitle: String
    var notiBody: String
    //    var osVersion: String
    //    var localizedModel: String
    //    var productName: String
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
}
