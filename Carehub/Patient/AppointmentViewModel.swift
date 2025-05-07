import FirebaseFirestore
import SwiftUI

class AppointmentViewModel: ObservableObject {
    private var db = Firestore.firestore()

    @Published var recentPrescriptions: [Appointment] = []
    @Published var errorMessage: String?

    func fetchRecentPrescriptions(forPatientId patientId: String) {
        print("Fetching prescriptions for patient ID: \(patientId)")
        
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patientId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    print("Error fetching documents: \(error.localizedDescription)")
                    return
                }
                
                print("Fetched documents: \(querySnapshot?.documents.count ?? 0)")

                self.recentPrescriptions = querySnapshot?.documents.compactMap { document in
                    print("Processing document with ID: \(document.documentID)")
                    if let apptId = document.data()["apptId"] as? String,
                       let patientId = document.data()["patientId"] as? String,
                       let description = document.data()["description"] as? String,
                       let docId = document.data()["docId"] as? String,
                       let status = document.data()["status"] as? String,
                       let billingStatus = document.data()["billingStatus"] as? String,
                       let amount = document.data()["amount"] as? Double,
                       let dateTimestamp = document.data()["date"] as? Timestamp,
                       let doctorsNotes = document.data()["doctorsNotes"] as? String,
                       let prescriptionId = document.data()["prescriptionId"] as? String,
                       let followUpRequired = document.data()["followUpRequired"] as? Bool,
                       let followUpDateTimestamp = document.data()["followUpDate"] as? Timestamp {
                        
                        // Convert timestamps to Date
                        let date = dateTimestamp.dateValue()
                        let followUpDate = followUpDateTimestamp.dateValue()
                        
                        // Create an Appointment object
                        let appointment = Appointment(
                            id: apptId,
                            apptId: apptId,
                            patientId: patientId,
                            description: description,
                            docId: docId,
                            status: status,
                            billingStatus: billingStatus,
                            amount: amount,
                            date: date,
                            doctorsNotes: doctorsNotes,
                            prescriptionId: prescriptionId,
                            followUpRequired: followUpRequired,
                            followUpDate: followUpDate
                        )
                        
                        print("Successfully decoded appointment with ID: \(appointment.apptId)") // Debugging decoded appointment
                        return appointment
                    } else {
                        print("Failed to decode appointment for document ID: \(document.documentID)") // Debugging decoding failure
                        return nil
                    }
                } ?? []
                print("Total prescriptions fetched: \(self.recentPrescriptions.count)")
            }
    }
}
