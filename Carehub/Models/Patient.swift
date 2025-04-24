//
//  Patient.swift
//  Carehub
//
//  Created by user@87 on 23/04/25.
//

import SwiftUI
import FirebaseFirestore

struct PatientF{
    var emergencyContact: [EmergencyContact]
    var medicalRecords: [MedicalRecord]
    var testResults: [TestResult]
    var userData: UserData
    var vitals: Vitals
    var lastModified: Date
    var patientId: String
    var username: String
}

struct EmergencyContact{
    var Number: String
    var name: String
}

struct MedicalRecord{
    var name: String
    var url: String
}

struct TestResultF {
    var dateCreated: Date
    var labTechId: String
    var testType: String
    var url: String
}

struct UserData{
    var Address: String
    var Dob: String
    var Email: String
    var Name: String
    var Password: String
    var aadharNo: String
    var phoneNo: String
}

struct Vitals{
    var allergies: [String]
    var bp: [VitalEntry]
    var heartRate: [VitalEntry]
    var height: [VitalEntry]
    var temperature: [VitalEntry]
    var weight: [VitalEntry]
}

struct VitalEntry{
    var timestamp: Date
    var value: String
}
