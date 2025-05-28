import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var displayName: String
    var username: String
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
        username: String? = nil,
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
        self.username = username ?? Self.generateUsername(from: displayName)
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        uid = try container.decode(String.self, forKey: .uid)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decode(String.self, forKey: .displayName)
        
        if let existingUsername = try container.decodeIfPresent(String.self, forKey: .username) {
            username = existingUsername
        } else {
            username = Self.generateUsername(from: displayName)
            print("🔄 Migrating user: Generated username '\(username)' for user '\(displayName)'")
        }
        
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        userTypes = try container.decodeIfPresent([UserType].self, forKey: .userTypes) ?? [.amateur_barista]
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        verificationRequested = try container.decodeIfPresent(Bool.self, forKey: .verificationRequested) ?? false
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? true
        joinDate = try container.decodeIfPresent(Date.self, forKey: .joinDate) ?? Date()
        followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount) ?? 0
        followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount) ?? 0
        preparationsCount = try container.decodeIfPresent(Int.self, forKey: .preparationsCount) ?? 0
        
        _id = try DocumentID<String>(from: decoder)
    }
    
    private static func generateUsername(from displayName: String) -> String {
        let cleanName = displayName
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "[^a-z0-9_]", with: "", options: .regularExpression)
        
        return cleanName.isEmpty ? "coffee_lover" : cleanName
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