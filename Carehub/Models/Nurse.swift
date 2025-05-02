//
//  Nurse.swift
//  Carehub
//
//  Created by user@87 on 23/04/25.
//

import Foundation
import FirebaseFirestore


struct Nurse: Identifiable, Codable {
    let id: String
    let name: String
    let nurseld: String
    let phoneNo: String?
    let email: String
    let shift: Shift?
    let createdAt: Timestamp?
    
    struct Shift: Codable {
        let startTime: String
        let endTime: String
    }
    
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let name = data["fullName"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.nurseld = id // Map id to nurseld
        self.email = email
        self.phoneNo = data["phoneNumber"] as? String
        self.createdAt = data["createdAt"] as? Timestamp
        
        if let shiftData = data["shift"] as? [String: String],
           let startTime = shiftData["startTime"],
           let endTime = shiftData["endTime"] {
            self.shift = Shift(startTime: startTime, endTime: endTime)
        } else {
            self.shift = nil
        }
    }
}
