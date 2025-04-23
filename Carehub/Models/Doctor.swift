//
//  Doctor.swift
//  Carehub
//
//  Created by user@87 on 23/04/25.
//

import SwiftUI
import FirebaseFirestore

struct Doctor {
    var Department: String
    var Doctor_experience: Int
    var Doctor_name: String
    var Doctorid: String
    var Email: String
    var ImageURL: String
    var Password: String
    var consultationFee: Double
    var department: String
    var doctorsNotes: [DoctorsNote]
    var license_number: String
    var phoneNo: String
}

struct DoctorsNote{
    var appointmentID: String
    var note: String
    var patientID: String
}
