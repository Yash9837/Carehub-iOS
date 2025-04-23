import Foundation
import FirebaseFirestore

class FirebaseAccountantService {
    private let db = Firestore.firestore()
    
    func fetchAccountant(byAccountantId accountantId: String, completion: @escaping (Result<Accountant, Error>) -> Void) {
        db.collection("accountants").document(accountantId)
            .getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let data = document.data() else {
                    completion(.failure(NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Accountant not found"])))
                    return
                }
                
                do {
                    guard let shiftData = data["Shift"] as? [String: String],
                          let startTime = shiftData["startTime"],
                          let endTime = shiftData["endTime"] else {
                        throw NSError(domain: "ParsingError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to parse shift data"])
                    }
                    
                    let shift = Accountant.Shift(endTime: endTime, startTime: startTime)
                    let accountant = Accountant(
                        email: data["Email"] as? String ?? "",
                        name: data["Name"] as? String ?? "",
                        password: data["Password"] as? String,
                        shift: shift,
                        accountantId: data["accountantId"] as? String ?? accountantId,
                        createdAt: data["createdAt"] as? Timestamp,
                        phoneNo: data["phoneNo"] as? String ?? ""
                    )
                    
                    completion(.success(accountant))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    func updateShiftHours(accountantId: String, newStart: String, newEnd: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("accountants").document(accountantId)
            .updateData([
                "Shift.startTime": newStart,
                "Shift.endTime": newEnd
            ], completion: completion)
    }
}
///Accountant View Model

class AccountantViewModel: ObservableObject {
    @Published var accountant: Accountant?
    @Published var isLoading = false
    @Published var error: Error?

    private let accountantService = FirebaseAccountantService()
    
    func fetchAccountant(byAccountantId accountantId: String) {
        isLoading = true
        error = nil
        
        accountantService.fetchAccountant(byAccountantId: accountantId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let accountant):
                    self?.accountant = accountant
                case .failure(let err):
                    self?.error = err
                    print("Error fetching accountant: \(err.localizedDescription)")
                }
            }
        }
    }
    
    func updateShiftHours(accountantId: String, newStart: String, newEnd: String) {
        accountantService.updateShiftHours(accountantId: accountantId, newStart: newStart, newEnd: newEnd) { [weak self] error in
            if let error = error {
                print("Error updating shift: \(error.localizedDescription)")
            } else {
                print("Shift updated successfully")
                self?.fetchAccountant(byAccountantId: accountantId)
            }
        }
    }
}

///Generate Bill View Model

class GenerateBillViewModel: ObservableObject {
    @Published var paidAppointments: [Appointment] = []
    @Published var unpaidAppointments: [Appointment] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchAppointments(forPatientId patientId: String) {
        isLoading = true
        error = nil
        paidAppointments = []
        unpaidAppointments = []
        
        print("Fetching appointments for patientId: \(patientId)")
        
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patientId)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.error = error
                        print("Error fetching appointments: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        self?.error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No appointments found"])
                        print("No appointments found for patientId: \(patientId)")
                        return
                    }
                    
                    print("Found \(documents.count) appointment(s) for patientId: \(patientId)")
                    
                    var paid: [Appointment] = []
                    var unpaid: [Appointment] = []
                    
                    for document in documents {
                        let data = document.data()
                        let id = document.documentID
                        
                        print("Processing appointment with documentId: \(id)")
                        
                        // Match the actual fields in your document
                        guard let patientId = data["patientId"] as? String,
                              let description = data["Description"] as? String,  // Note: capital D
                              let docId = data["docId"] as? String,
                              let status = data["Status"] as? String,            // Note: capital S
                              let billingStatus = data["billingStatus"] as? String,
                              let apptId = data["apptId"] as? String
                        else {
                            print("Skipping malformed document with documentId: \(id)")
                            // Debug which fields are missing
                            if data["patientId"] as? String == nil { print("- Missing patientId") }
                            if data["Description"] as? String == nil { print("- Missing Description") }
                            if data["docId"] as? String == nil { print("- Missing docId") }
                            if data["Status"] as? String == nil { print("- Missing Status") }
                            if data["billingStatus"] as? String == nil { print("- Missing billingStatus") }
                            if data["apptId"] as? String == nil { print("- Missing apptId") }
                            continue
                        }
                        
                        // Optional fields
                        let doctorsNotes = data["doctorsNotes"] as? String
                        let prescriptionId = data["prescriptionId"] as? String
                        let followUpRequired = data["followUpRequired"] as? Bool
                        let amount = data["amount"] as? Double
                        
                        // Handle date fields
                        var date: Date? = nil
                        if let timestamp = data["Date"] as? Timestamp {
                            date = timestamp.dateValue()
                        }
                        
                        var followUpDate: Date? = nil
                        if let timestamp = data["followUpDate"] as? Timestamp {
                            followUpDate = timestamp.dateValue()
                        }
                        
                        print("Created appointment: \(description), billingStatus: \(billingStatus)")
                        
                        let appointment = Appointment(
                            id: id,
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
                        
                        // Sort into appropriate array
                        if billingStatus.lowercased() == "paid" {
                            paid.append(appointment)
                        } else {
                            unpaid.append(appointment)
                        }
                    }
                    
                    self?.paidAppointments = paid
                    self?.unpaidAppointments = unpaid
                    
                    print("Total paid appointments: \(paid.count)")
                    print("Total unpaid appointments: \(unpaid.count)")
                }
            }
    }

    
    func markAsPaid(appointmentId: String, completion: @escaping (Bool) -> Void) {
        db.collection("appointments").document(appointmentId)
            .updateData(["billingStatus": "paid"]) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error updating appointment: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        // Update local data arrays
                        if let index = self?.unpaidAppointments.firstIndex(where: { $0.id == appointmentId }) {
                            guard let appointment = self?.unpaidAppointments[index] else {
                                completion(false)
                                return
                            }
                            
                            // Create updated appointment with all fields from original appointment
                            let updatedAppointment = Appointment(
                                id: appointment.id,
                                apptId: appointment.apptId,
                                patientId: appointment.patientId,
                                description: appointment.description,
                                docId: appointment.docId,
                                status: appointment.status,
                                billingStatus: "paid",
                                amount: appointment.amount,
                                date: appointment.date,
                                doctorsNotes: appointment.doctorsNotes,
                                prescriptionId: appointment.prescriptionId,
                                followUpRequired: appointment.followUpRequired,
                                followUpDate: appointment.followUpDate
                            )
                            
                            self?.paidAppointments.append(updatedAppointment)
                            self?.unpaidAppointments.remove(at: index)
                        }
                        completion(true)
                    }
                }
            }
    }
}
