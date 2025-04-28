////
////  Nurse.swift
////  Carehub
////
////  Created by user@87 on 23/04/25.
////
//import Foundation
//import FirebaseFirestore
//
//struct Nurse: Identifiable {
//    var id: String { nurseld } // Firestore document ID
//    let name: String
//    let email: String
//    let phoneNo: String
//    let department: String
//    let password: String
//    let shift: Shift
//    let createdAt: Timestamp?
//    let nurseld: String
//
//    struct Shift {
//        let startTime: String
//        let endTime: String
//    }
//
//    init?(from data: [String: Any]) {
//        guard
//            let name = data["Name"] as? String,
//            let email = data["Email"] as? String,
//            let phoneNo = data["phoneNo"] as? String,
//            let department = data["Department"] as? String,
//            let password = data["Password"] as? String,
//            let nurseld = data["nurseld"] as? String,
//            let shiftData = data["Shift"] as? [String: String],
//            let startTime = shiftData["startTime"],
//            let endTime = shiftData["endTime"]
//        else { return nil }
//
//        self.name = name
//        self.email = email
//        self.phoneNo = phoneNo
//        self.department = department
//        self.password = password
//        self.shift = Shift(startTime: startTime, endTime: endTime)
//        self.createdAt = data["createdAt"] as? Timestamp
//        self.nurseld = nurseld
//    }
//}
//
