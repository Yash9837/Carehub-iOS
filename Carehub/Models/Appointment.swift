import SwiftUI

struct Appointment: Identifiable, Decodable {
    var id: String
    let apptId: String
    let patientId: String
    let description: String
    let docId: String
    let status: String
    let billingStatus: String
    let amount: Double?
    let date: Date?
    let doctorsNotes: String?
    let prescriptionId: String?
    let followUpRequired: Bool?
    let followUpDate: Date?
}

