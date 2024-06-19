import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    var notificationId: String
//    var notificationId = UUID()
    var notiTitle: String
    var notiBody: String
    var notiTopic: String
    var notiType: String // Added [2024/06/18]
  //  var isMeResponded: Bool?
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case notificationId
        case notiTitle
        case notiBody
        case notiTopic
        case notiType
//        case isMeResponded
        case createdAt
        case updatedAt
    }
    
    init(
        id: String? = nil,
        notificationId: String,
        notiTitle: String,
        notiBody: String,
        notiTopic: String,
        notiType: String
    //    isMeResponded: Bool?
    ) {
        self.id = id
        self.notificationId = notificationId
        self.notiTitle = notiTitle
        self.notiBody = notiBody
        self.notiTopic = notiTopic
        self.notiType = notiType
//        self.isMeResponded = isMeResponded
    }
}
