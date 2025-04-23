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
