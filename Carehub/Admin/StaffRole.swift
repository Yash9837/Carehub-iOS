// StaffRole.swift

import Foundation


enum StaffRole: String, CaseIterable, Codable, Identifiable {
    case doctor = "Doctor"
    case nurse = "Nurse"
    case labTechnician = "Lab Technician"
    case admin = "Admin"
    
    var id: String { self.rawValue }
    
    var prefix: String {
        switch self {
        case .doctor: return "D"
        case .nurse: return "N"
        case .labTechnician: return "L"
        case .admin: return "A"
        }
    }
}

// Staff.swift
struct Staff: Identifiable, Codable {
    let id: String
    var fullName: String
    var email: String
    var role: StaffRole
    var department: String
    var phoneNumber: String
    var joinDate: Date
    
    // Add CodingKeys if you want to customize the JSON keys
    enum CodingKeys: String, CodingKey {
        case id, fullName, email, role, department, phoneNumber, joinDate
    }
    
    init(fullName: String, email: String, role: StaffRole, department: String, phoneNumber: String) {
        self.fullName = fullName
        self.email = email
        self.role = role
        self.department = department
        self.phoneNumber = phoneNumber
        self.joinDate = Date()
        
        // Generate ID with prefix and random number
        let randomNum = String(format: "%06d", Int.random(in: 0..<1000000))
        self.id = "\(role.prefix)\(randomNum)"
    }
}
