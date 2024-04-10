import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    var notiTitle: String
    var notiBody: String
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case notiTitle
        case notiBody
        case createdAt
        case updatedAt
    }
    
    init(id: String? = nil, notiTitle: String, notiBody: String) {
        self.id = id
        self.notiTitle = notiTitle
        self.notiBody = notiBody
    }
}
