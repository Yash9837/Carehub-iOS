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
                    
                    var paid: [Appointment] = []
                    var unpaid: [Appointment] = []
                    
                    for document in documents {
                        let data = document.data()
                        let id = document.documentID
                        
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
                        return
                    }

                    guard let index = self?.unpaidAppointments.firstIndex(where: { $0.id == appointmentId }),
                          let appointment = self?.unpaidAppointments[index] else {
                        completion(false)
                        return
                    }

                    // Step 1: Fetch consultation fee from the doctor's document
                    self?.db.collection("doctors").document(appointment.docId).getDocument { snapshot, error in
                        if let error = error {
                            print("Error fetching doctor: \(error.localizedDescription)")
                            completion(false)
                            return
                        }

                        guard let data = snapshot?.data(),
                              let consultationFee = data["consultationFee"] as? Double else {
                            print("Consultation fee not found or invalid.")
                            completion(false)
                            return
                        }

                        // Step 2: Create updated appointment
                        let updatedAppointment = Appointment(
                            id: appointment.id,
                            apptId: appointment.apptId,
                            patientId: appointment.patientId,
                            description: appointment.description,
                            docId: appointment.docId,
                            status: appointment.status,
                            billingStatus: "paid",
                            amount: consultationFee,
                            date: appointment.date,
                            doctorsNotes: appointment.doctorsNotes,
                            prescriptionId: appointment.prescriptionId,
                            followUpRequired: appointment.followUpRequired,
                            followUpDate: appointment.followUpDate
                        )

                        self?.paidAppointments.append(updatedAppointment)
                        self?.unpaidAppointments.remove(at: index)

                        // Step 3: Create billing document
                        let billingId = UUID().uuidString
                        let billItems: [[String: Any]] = [
                            [
                                "fee": consultationFee,
                                "isPaid": true,
                                "itemName": appointment.description
                            ]
                        ]
                        let billingData: [String: Any] = [
                            "billingId": billingId,
                            "bills": billItems,
                            "appointmentId": appointment.id,
                            "billingStatus": "paid",
                            "date": Timestamp(date: Date()),
                            "doctorId": appointment.docId,
                            "insuranceAmt": 0.0,
                            "paidAmt": consultationFee,
                            "patientId": appointment.patientId,
                            "paymentMode": "Cash" // Or make this dynamic
                        ]

                        self?.db.collection("billing").document(billingId).setData(billingData) { error in
                            if let error = error {
                                print("Failed to add billing document: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
                }
            }
    }
}

/// Payments View Model

class PaymentsViewModel: ObservableObject {
    @Published var payments: [Billing] = []
    @Published var error: Error?
    @Published var isLoading = false
    @Published var patientNames: [String: String] = [:]
    @Published var doctorNames: [String: String] = [:]
    
    private let db = Firestore.firestore()
    
    func getBills() {
        isLoading = true
        error = nil
        
        db.collection("billing")
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                defer {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let fetchedBills: [Billing] = documents.compactMap { doc in
                    let data = doc.data()
                    let billingId = data["billingId"] as? String ?? doc.documentID
                    let appointmentId = data["appointmentId"] as? String ?? ""
                    let billingStatus = data["billingStatus"] as? String ?? ""
                    let doctorId = data["doctorId"] as? String ?? ""
                    let patientId = data["patientId"] as? String ?? ""
                    let paymentMode = data["paymentMode"] as? String ?? ""
                    let insuranceAmt = data["insuranceAmt"] as? Double ?? 0.0
                    let paidAmt = data["paidAmt"] as? Double ?? 0.0
                    let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    
                    let billItems: [BillItem]
                    if let items = data["bills"] as? [[String: Any]] {
                        billItems = items.compactMap { item in
                            guard let itemName = item["itemName"] as? String,
                                  let fee = item["fee"] as? Double,
                                  let isPaid = item["isPaid"] as? Bool else {
                                return nil
                            }
                            return BillItem(fee: fee, isPaid: isPaid, itemName: itemName)
                        }
                    } else {
                        billItems = []
                    }
                    
                    return Billing(
                        billingId: billingId,
                        bills: billItems,
                        appointmentId: appointmentId,
                        billingStatus: billingStatus,
                        date: date,
                        doctorId: doctorId,
                        insuranceAmt: insuranceAmt,
                        paidAmt: paidAmt,
                        patientId: patientId,
                        paymentMode: paymentMode
                    )
                }
                
                DispatchQueue.main.async {
                    self.payments = fetchedBills
                    self.fetchPatientAndDoctorNames(from: fetchedBills)
                }
            }
    }
    
    func fetchPatientAndDoctorNames(from bills: [Billing]) {
        let patientIDs = Set(bills.map { $0.patientId })
        let doctorIDs = Set(bills.map { $0.doctorId })
        
        // Fetch patient names
        for patientId in patientIDs where !patientId.isEmpty {
            db.collection("patients").document(patientId).getDocument { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else { return }
                
                let name = (data["userData"] as? [String: Any])?["Name"] as? String ?? ""
                
                DispatchQueue.main.async {
                    self.patientNames[patientId] = name.isEmpty ? "Unknown Patient" : name
                }
            }
        }
        
        // Fetch doctor names
        for doctorId in doctorIDs where !doctorId.isEmpty {
            db.collection("doctors").document(doctorId).getDocument { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else { return }
                
                let name = data["Doctor_name"] as? String ?? ""
                let specialty = data["Department"] as? String ?? ""
                let displayName = name.isEmpty ? "Unknown Doctor" : "Dr. \(name)" + (specialty.isEmpty ? "" : " (\(specialty))")
                
                DispatchQueue.main.async {
                    self.doctorNames[doctorId] = displayName
                }
            }
        }
    }
}
