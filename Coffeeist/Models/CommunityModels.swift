import Foundation
import FirebaseFirestore

// MARK: - Follow System
struct Follow: Identifiable, Codable {
    @DocumentID var id: String?
    var follower: String // User UID
    var following: String // User UID
    var createdAt: Date
    
    init(
        follower: String,
        following: String,
        createdAt: Date = Date()
    ) {
        self.follower = follower
        self.following = following
        self.createdAt = createdAt
    }
}

// MARK: - Clubs/Communities
struct Club: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var location: String?
    var createdBy: String // User UID
    var createdAt: Date
    var memberCount: Int
    var isPublic: Bool
    var imageURL: String?
    var tags: [String]? // Coffee-related tags
    
    init(
        name: String,
        description: String,
        location: String? = nil,
        createdBy: String,
        createdAt: Date = Date(),
        memberCount: Int = 1,
        isPublic: Bool = true,
        imageURL: String? = nil,
        tags: [String]? = nil
    ) {
        self.name = name
        self.description = description
        self.location = location
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.memberCount = memberCount
        self.isPublic = isPublic
        self.imageURL = imageURL
        self.tags = tags
    }
}

struct ClubMembership: Identifiable, Codable {
    @DocumentID var id: String?
    var clubId: String
    var userId: String
    var role: ClubRole
    var joinedAt: Date
    
    init(
        clubId: String,
        userId: String,
        role: ClubRole = .member,
        joinedAt: Date = Date()
    ) {
        self.clubId = clubId
        self.userId = userId
        self.role = role
        self.joinedAt = joinedAt
    }
}

enum ClubRole: String, CaseIterable, Codable {
    case owner = "owner"
    case admin = "admin"
    case moderator = "moderator"
    case member = "member"
    
    var displayName: String {
        switch self {
        case .owner:
            return "Owner"
        case .admin:
            return "Admin"
        case .moderator:
            return "Moderator"
        case .member:
            return "Member"
        }
    }
    
    var canModerate: Bool {
        return self == .owner || self == .admin || self == .moderator
    }
    
    var canManageMembers: Bool {
        return self == .owner || self == .admin
    }
}

// MARK: - Brand Pages
struct BrandPage: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var website: String?
    var logoURL: String?
    var location: String?
    var ownerId: String // User UID who manages this brand page
    var isVerified: Bool
    var followersCount: Int
    var createdAt: Date
    var brandType: BrandType
    var contactInfo: BrandContactInfo?
    
    init(
        name: String,
        description: String,
        website: String? = nil,
        logoURL: String? = nil,
        location: String? = nil,
        ownerId: String,
        isVerified: Bool = false,
        followersCount: Int = 0,
        createdAt: Date = Date(),
        brandType: BrandType = .roaster,
        contactInfo: BrandContactInfo? = nil
    ) {
        self.name = name
        self.description = description
        self.website = website
        self.logoURL = logoURL
        self.location = location
        self.ownerId = ownerId
        self.isVerified = isVerified
        self.followersCount = followersCount
        self.createdAt = createdAt
        self.brandType = brandType
        self.contactInfo = contactInfo
    }
}

enum BrandType: String, CaseIterable, Codable {
    case roaster = "roaster"
    case cafe = "cafe"
    case equipment = "equipment"
    case distributor = "distributor"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .roaster:
            return "Coffee Roaster"
        case .cafe:
            return "Café"
        case .equipment:
            return "Equipment Manufacturer"
        case .distributor:
            return "Distributor"
        case .other:
            return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .roaster:
            return "flame.fill"
        case .cafe:
            return "cup.and.saucer.fill"
        case .equipment:
            return "gear"
        case .distributor:
            return "shippingbox.fill"
        case .other:
            return "building.2.fill"
        }
    }
}

struct BrandContactInfo: Codable {
    var email: String?
    var phone: String?
    var address: String?
    var socialMedia: [String: String]? // Platform name -> handle/URL
    
    init(
        email: String? = nil,
        phone: String? = nil,
        address: String? = nil,
        socialMedia: [String: String]? = nil
    ) {
        self.email = email
        self.phone = phone
        self.address = address
        self.socialMedia = socialMedia
    }
}

struct BrandFollower: Identifiable, Codable {
    @DocumentID var id: String?
    var brandId: String
    var userId: String
    var followedAt: Date
    
    init(
        brandId: String,
        userId: String,
        followedAt: Date = Date()
    ) {
        self.brandId = brandId
        self.userId = userId
        self.followedAt = followedAt
    }
} 