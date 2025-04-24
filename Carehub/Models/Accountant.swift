//
//  Accountant.swift
//  Carehub
//
//  Created by user@87 on 23/04/25.
//
import SwiftUI
import FirebaseFirestore

struct Accountant: Identifiable, Codable {
    var id: String { accountantId }
    var email: String
    var name: String
    var password: String?  // Include but mark as optional since we may not want to expose this
    var shift: Shift
    var accountantId: String
    var createdAt: Timestamp?  // Using Firestore Timestamp
    var phoneNo: String
    
    struct Shift: Codable {
        var endTime: String
        var startTime: String
    }
    
    // Ensuring exact field names from the database
    enum CodingKeys: String, CodingKey {
        case email = "Email"
        case name = "Name"
        case password = "Password"
        case shift = "Shift"
        case accountantId = "accountantId"
        case createdAt = "createdAt"
        case phoneNo = "phoneNo"
    }
}
