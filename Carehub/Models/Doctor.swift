//
//  Doctor.swift
//  Carehub
//
//  Created by user@87 on 23/04/25.
//

//import SwiftUI
//import FirebaseFirestore
//
//struct Doctor {
//    var Department: String
//    var Doctor_experience: Int
//    var Doctor_name: String
//    var Doctorid: String
//    var Email: String
//    var ImageURL: String
//    var Password: String
//    var consultationFee: Double
//    var department: String
//    var doctorsNotes: [DoctorsNote]
//    var license_number: String
//    var phoneNo: String
//}
//
//struct DoctorsNote{
//    var appointmentID: String
//    var note: String
//    var patientID: String
//}

import Foundation
import FirebaseFirestore

struct Doctor: Identifiable, Codable {
    let id: String
    let department: String
    let doctor_name: String
    let doctor_experience: Int?
    let email: String?
    let imageURL: String?
    let password: String?
    let consultationFee: Int?
    let license_number: String?
    let phoneNo: String?

    enum CodingKeys: String, CodingKey {
        case id = "Doctorid" // Matches Firestore field
        case department = "Filed_name" // Correcting typo, assuming it should be Department
        case doctor_name = "Doctor_name"
        case doctor_experience = "Doctor_experience"
        case email = "Email"
        case imageURL = "ImageURL"
        case password = "Password"
        case consultationFee = "consultationFee"
        case license_number = "license_number"
        case phoneNo = "phoneNo"
    }
}

class DoctorData {
    static let db = Firestore.firestore()
    static var specialties: [String] = []
    static var doctors: [String: [Doctor]] = [:]
    
    static func fetchDoctors(completion: @escaping () -> Void) {
        db.collection("doctors").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching doctors: \(error.localizedDescription)")
                completion()
                return
            }
            
            var tempSpecialties: Set<String> = []
            var tempDoctors: [String: [Doctor]] = [:]
            
            for document in querySnapshot?.documents ?? [] {
                print("Raw document data: \(document.data())")
                do {
                    let doctor = try document.data(as: Doctor.self)
                    print("Successfully decoded doctor: \(doctor.id) - \(doctor.doctor_name) (\(doctor.department))")
                    tempSpecialties.insert(doctor.department)
                    if var departmentDoctors = tempDoctors[doctor.department] {
                        departmentDoctors.append(doctor)
                        tempDoctors[doctor.department] = departmentDoctors
                    } else {
                        tempDoctors[doctor.department] = [doctor]
                    }
                } catch {
                    print("Error decoding doctor from \(document.documentID): \(error.localizedDescription)")
                }
            }
            
            specialties = Array(tempSpecialties).sorted()
            doctors = tempDoctors
            print("Specialties: \(specialties)")
            print("Doctors by specialty: \(doctors.mapValues { $0.map { $0.doctor_name } })")
            completion()
        }
    }
}
