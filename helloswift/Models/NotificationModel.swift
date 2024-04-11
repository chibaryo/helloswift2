import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    var notificationId = UUID()
    var notiTitle: String
    var notiBody: String
    var notiTopic: String
  //  var isMeResponded: Bool?
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case notificationId
        case notiTitle
        case notiBody
        case notiTopic
//        case isMeResponded
        case createdAt
        case updatedAt
    }
    
    init(
        id: String? = nil,
        notiTitle: String,
        notiBody: String,
        notiTopic: String
    //    isMeResponded: Bool?
    ) {
        self.id = id
        self.notiTitle = notiTitle
        self.notiBody = notiBody
        self.notiTopic = notiTopic
//        self.isMeResponded = isMeResponded
    }
}
