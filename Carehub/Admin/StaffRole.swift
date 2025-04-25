<<<<<<< Updated upstream
<<<<<<< Updated upstream
// StaffRole.swift

import Foundation

=======
import Foundation
import FirebaseFirestore
>>>>>>> Stashed changes
=======
import Foundation
import FirebaseFirestore
>>>>>>> Stashed changes

enum StaffRole: String, CaseIterable, Codable, Identifiable {
    case doctor = "Doctor"
    case nurse = "Nurse"
    case labTechnician = "Lab Technician"
    case admin = "Admin"
    
    var id: String { self.rawValue }
    
    var collectionName: String {
        switch self {
        case .doctor: return "doctors"
        case .nurse: return "nurses"
        case .labTechnician: return "labtechs"
        case .admin: return "admins"
        }
    }
}

struct Staff: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore-managed ID
    var fullName: String
    var email: String
    var role: StaffRole
    var department: String?
    var phoneNumber: String?
    var joinDate: Date?
    var profileImageURL: String?
<<<<<<< Updated upstream
    
<<<<<<< Updated upstream
    // Add CodingKeys if you want to customize the JSON keys
    enum CodingKeys: String, CodingKey {
        case id, fullName, email, role, department, phoneNumber, joinDate
    }
    
    init(fullName: String, email: String, role: StaffRole, department: String, phoneNumber: String) {
=======
=======
    
>>>>>>> Stashed changes
    enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case email
        case role
        case department
        case phoneNumber
        case joinDate
        case profileImageURL = "imageUrl"
    }
    
    init(id: String? = nil,
         fullName: String,
         email: String,
         role: StaffRole,
         department: String? = nil,
         phoneNumber: String? = nil,
         joinDate: Date? = nil,
         profileImageURL: String? = nil) {
        self.id = id
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
        self.fullName = fullName
        self.email = email
        self.role = role
        self.department = department
        self.phoneNumber = phoneNumber
        self.joinDate = joinDate
        self.profileImageURL = profileImageURL
    }
}
