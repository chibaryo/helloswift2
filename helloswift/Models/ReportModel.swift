import FirebaseFirestore
import FirebaseFirestoreSwift

struct ReportModel: Identifiable, Codable {
    @DocumentID var id: String?
    var notificationId: String
    var uid: String
    var injuryStatus: String
    var attendOfficeStatus: String
    var location: String
    var message: String
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case notificationId
        case uid
        case injuryStatus
        case attendOfficeStatus
        case location
        case message
        case createdAt
        case updatedAt
    }
    
    init(
        id: String? = nil,
        notificationId: String,
        uid: String,
        injuryStatus: String,
        attendOfficeStatus: String,
        location: String,
        message: String
    ) {
        self.id = id
        self.notificationId = notificationId
        self.uid = uid
        self.injuryStatus = injuryStatus
        self.attendOfficeStatus = attendOfficeStatus
        self.location = location
        self.message = message
    }
}
