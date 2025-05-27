import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var displayName: String
    var profileImageURL: String?
    var bio: String?
    var location: String?
    var userTypes: [UserType]
    var isVerified: Bool
    var verificationRequested: Bool
    var isPublic: Bool
    var joinDate: Date
    var followersCount: Int
    var followingCount: Int
    var preparationsCount: Int
    
    init(
        uid: String,
        email: String,
        displayName: String,
        profileImageURL: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        userTypes: [UserType] = [.amateur_barista],
        isVerified: Bool = false,
        verificationRequested: Bool = false,
        isPublic: Bool = true,
        joinDate: Date = Date(),
        followersCount: Int = 0,
        followingCount: Int = 0,
        preparationsCount: Int = 0
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.location = location
        self.userTypes = userTypes
        self.isVerified = isVerified
        self.verificationRequested = verificationRequested
        self.isPublic = isPublic
        self.joinDate = joinDate
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.preparationsCount = preparationsCount
    }
}

enum UserType: String, CaseIterable, Codable {
    case professional_barista = "professional_barista"
    case amateur_barista = "amateur_barista"
    case aficionado = "aficionado"
    case content_creator = "content_creator"
    case brand = "brand"
    case retail_location = "retail_location"
    
    var displayName: String {
        switch self {
        case .professional_barista:
            return "Professional Barista"
        case .amateur_barista:
            return "Amateur Barista"
        case .aficionado:
            return "Coffee Aficionado"
        case .content_creator:
            return "Content Creator"
        case .brand:
            return "Brand"
        case .retail_location:
            return "Retail Location"
        }
    }
    
    var icon: String {
        switch self {
        case .professional_barista:
            return "star.fill"
        case .amateur_barista:
            return "cup.and.saucer.fill"
        case .aficionado:
            return "heart.fill"
        case .content_creator:
            return "camera.fill"
        case .brand:
            return "building.2.fill"
        case .retail_location:
            return "storefront.fill"
        }
    }
} 