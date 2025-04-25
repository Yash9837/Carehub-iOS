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
    let pdfUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case patientId
        case testName
        case date
        case status
        case results
        case notes
        case pdfUrl
    }
    
    init(id: String = UUID().uuidString,
         patientId: String,
         testName: String,
         date: String,
         status: String,
         results: String,
         notes: String,
         pdfUrl: String = "") {
        self.id = id
        self.patientId = patientId
        self.testName = testName
        self.date = date
        self.status = status
        self.results = results
        self.notes = notes
        self.pdfUrl = pdfUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        patientId = try container.decode(String.self, forKey: .patientId)
        testName = try container.decode(String.self, forKey: .testName)
        date = try container.decode(String.self, forKey: .date)
        status = try container.decode(String.self, forKey: .status)
        results = try container.decode(String.self, forKey: .results)
        notes = try container.decode(String.self, forKey: .notes)
        pdfUrl = try container.decodeIfPresent(String.self, forKey: .pdfUrl) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(patientId, forKey: .patientId)
        try container.encode(testName, forKey: .testName)
        try container.encode(date, forKey: .date)
        try container.encode(status, forKey: .status)
        try container.encode(results, forKey: .results)
        try container.encode(notes, forKey: .notes)
        try container.encode(pdfUrl, forKey: .pdfUrl)
    }
}
