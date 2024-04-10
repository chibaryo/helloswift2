import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var name: String
    var email: String
    var password: String
    var isAdmin: Bool
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case name
        case email
        case password
        case isAdmin
        case createdAt
        case updatedAt
    }
    
    init(id: String? = nil, uid: String, name: String, email: String, password: String, isAdmin: Bool) {
        self.id = id
        self.uid = uid
        self.name = name
        self.email = email
        self.password = password
        self.isAdmin = isAdmin
    }
}
