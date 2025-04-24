//
//  LabTech.swift
//  Carehub
//
//  Created by user@87 on 23/04/25.
//

import SwiftUI
import FirebaseFirestore

struct LabTechnician {
    var Department: String
    var Email: String
    var Name: String
    var Password: String
    var assignedReports: [AssignedReport]
    var phoneNo: String
    var shift: Shift
    var labTechId: String
}

struct AssignedReport{
    var Status: String
    var patientId: String
    var testName: String
}

struct Shift{
    var endTime: String
    var startTime: String
}

// Combined data structure to link MedicalTest with Patient1
struct PatientWithTest: Identifiable {
    let id: String // Use medicalTest id
    let patient: Patient1
    let medicalTest: MedicalTest
}

// Patient1 struct (from patients collection)
struct Patient1: Codable, Identifiable {
    let id: String // Firestore document ID
    let fullName: String
    let generatedID: String
    let age: String
    let previousProblems: String
    let allergies: String
    let medications: String
}

// MedicalTest struct (from medicalTests collection)
struct MedicalTest: Codable, Identifiable {
    let id: String // Firestore document ID
    let date: String
    let notes: String
    let patientId: String
    let results: String
    let status: String
    let testName: String
}

struct PatientInfo: Identifiable, Codable {
    @DocumentID var id: String?
    let fullName: String
    let generatedID: String
    let age: String
    let previousProblems: String
    let allergies: String
    let medications: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case generatedID
        case age
        case previousProblems
        case allergies
        case medications
    }
}

struct TestResult: Identifiable, Codable {
    let id: String
    let patientId: String
    let testName: String
    let date: String
    let status: String
    let results: String
    let notes: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case patientId
        case testName
        case date
        case status
        case results
        case notes
    }
    
    init(id: String = UUID().uuidString,
         patientId: String,
         testName: String,
         date: String,
         status: String,
         results: String,
         notes: String) {
        self.id = id
        self.patientId = patientId
        self.testName = testName
        self.date = date
        self.status = status
        self.results = results
        self.notes = notes
    }
}
