import FirebaseFirestore
import SwiftUI

class AppointmentViewModel: ObservableObject {
    private var db = Firestore.firestore()

    @Published var recentPrescriptions: [Appointment] = []
    @Published var errorMessage: String?
    // Dictionary to store the pdfUrl for each medical test, keyed by medicalTests id
    @Published var medicalTestPdfUrls: [String: String] = [:]

    func fetchRecentPrescriptions(forPatientId patientId: String) {
        print("Fetching prescriptions for patient ID: \(patientId)")
        // Step 1: Fetch medical tests for the patient
        fetchMedicalTests(forPatientId: patientId) {
            // Step 2: Fetch appointments after medical tests are loaded
            self.db.collection("appointments")
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
                            
                            let date = dateTimestamp.dateValue()
                            let followUpDate = followUpDateTimestamp.dateValue()
                            
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
                            
                            print("Successfully decoded appointment with ID: \(appointment.apptId)")
                            return appointment
                        } else {
                            print("Failed to decode appointment for document ID: \(document.documentID)")
                            return nil
                        }
                    } ?? []
                    print("Total prescriptions fetched: \(self.recentPrescriptions.count)")
                }
        }
    }
    
    private func fetchMedicalTests(forPatientId patientId: String, completion: @escaping () -> Void) {
        db.collection("medicalTests")
            .whereField("patientId", isEqualTo: patientId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching medical tests for patient ID \(patientId): \(error.localizedDescription)")
                    completion()
                    return
                }
                
                print("Fetched medical tests: \(querySnapshot?.documents.count ?? 0)")
                
                for document in querySnapshot?.documents ?? [] {
                    if let medicalTestId = document.data()["id"] as? String,
                       let pdfUrl = document.data()["pdfUrl"] as? String {
                        print("Found medical test ID \(medicalTestId) with pdfUrl: \(pdfUrl)")
                        self.medicalTestPdfUrls[medicalTestId] = pdfUrl
                    } else {
                        print("Failed to decode medical test document ID: \(document.documentID)")
                    }
                }
                
                completion()
            }
    }
}
