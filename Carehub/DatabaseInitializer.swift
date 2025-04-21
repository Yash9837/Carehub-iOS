import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DatabaseInitializer {
    static let db = Firestore.firestore()
    
    static func initializeDatabase(completion: @escaping (Bool, Error?) -> Void) {
        // Create all collections and documents in a batch to ensure atomic operation
        let batch = db.batch()
        
        // 1. Patients Collection
        let patientRef = db.collection("patients").document("PT001")
        let patientData: [String: Any] = [
            "userData": [
                "name": "John Doe",
                "email": "john.doe@example.com",
                "dob": "1985-05-15",
                "phoneNo": "+1234567890",
                "address": "123 Main St, Cityville",
                "aadharNo": "1234-5678-9012"
            ],
            "emergencyContacts": [
                [
                    "name": "Jane Doe",
                    "number": "+1987654321",
                    "relation": "Spouse"
                ]
            ],
            "medicalRecords": [
                [
                    "name": "Annual Checkup 2023",
                    "url": "https://storage.googleapis.com/medical-records/john-doe-checkup-2023.pdf"
                ]
            ],
            "testResults": [
                [
                    "testType": "Blood Test",
                    "dateCreated": Timestamp(date: Date()),
                    "labTechId": "LT001",
                    "url": "https://storage.googleapis.com/test-results/blood-test-john-doe-2023.pdf",
                    "status": "completed"
                ]
            ],
            "vitals": [
                "bp": "120/80",
                "weight": 75,
                "height": 175,
                "allergy": "Penicillin",
                "heartRate": 72,
                "temperature": 98.6
            ]
        ]
        batch.setData(patientData, forDocument: patientRef)
        
        // 2. Doctors Collection
        let doctorRef = db.collection("doctors").document("DOC001")
        let doctorData: [String: Any] = [
            "name": "Dr. Sarah Smith",
            "email": "sarah.smith@hospital.com",
            "phoneNo": "+1122334455",
            "field": [
                "id": "CARD01",
                "name": "Cardiology"
            ],
            "experience": 12,
            "licenseNumber": "MD123456",
            "department": "Cardiology",
            "shift": [
                "startTime": "08:00",
                "endTime": "17:00"
            ]
        ]
        batch.setData(doctorData, forDocument: doctorRef)
        
        // 3. Appointments Collection
        let appointmentRef = db.collection("appointments").document("APT001")
        let appointmentData: [String: Any] = [
            "patientId": "PT001",
            "docId": "DOC001",
            "date": Timestamp(date: Date()),
            "description": "Annual checkup",
            "status": "completed",
            "doctorsNotes": "Patient in good health, recommended annual blood work",
            "billingStatus": "paid",
            "prescriptionId": "RX001",
            "followUpRequired": true,
            "followUpDate": Timestamp(date: Calendar.current.date(byAdding: .month, value: 6, to: Date())!)
        ]
        batch.setData(appointmentData, forDocument: appointmentRef)
        
        // 4. Nurses Collection
        let nurseRef = db.collection("nurses").document("NUR001")
        let nurseData: [String: Any] = [
            "name": "Emma Johnson",
            "email": "emma.johnson@hospital.com",
            "phoneNo": "+1555666777",
            "shift": [
                "startTime": "07:00",
                "endTime": "19:00"
            ],
            "createdAt": Timestamp(date: Date()),
            "department": "Emergency"
        ]
        batch.setData(nurseData, forDocument: nurseRef)
        
        // 5. Lab Technicians Collection
        let labTechRef = db.collection("labTechs").document("LT001")
        let labTechData: [String: Any] = [
            "name": "Michael Chen",
            "email": "michael.chen@hospital.com",
            "phoneNo": "+1888999000",
            "department": "Pathology",
            "shift": [
                "startTime": "09:00",
                "endTime": "18:00"
            ],
            "assignedReports": [
                [
                    "patientId": "PT001",
                    "testName": "Complete Blood Count",
                    "status": "completed"
                ]
            ]
        ]
        batch.setData(labTechData, forDocument: labTechRef)
        
        // 6. Prescriptions Collection
        let prescriptionRef = db.collection("prescriptions").document("RX001")
        let prescriptionData: [String: Any] = [
            "appointmentId": "APT001",
            "patientId": "PT001",
            "doctorId": "DOC001",
            "createdAt": Timestamp(date: Date()),
            "medicines": [
                [
                    "name": "Atorvastatin",
                    "dosage": "20mg",
                    "frequency": "Once daily",
                    "duration": 30,
                    "instructions": "Take at bedtime"
                ]
            ]
        ]
        batch.setData(prescriptionData, forDocument: prescriptionRef)
        
        // 7. Billing Collection
        let billingRef = db.collection("billing").document("BIL001")
        let billingData: [String: Any] = [
            "patientId": "PT001",
            "doctorId": "DOC001",
            "appointmentId": "APT001",
            "date": Timestamp(date: Date()),
            "paymentMode": "Credit Card",
            "bills": [
                [
                    "itemName": "Consultation",
                    "fee": 150,
                    "isPaid": true
                ]
            ],
            "paidAmt": 150,
            "insuranceAmt": 0,
            "billingStatus": "paid"
        ]
        batch.setData(billingData, forDocument: billingRef)
        
        // 8. Admins Collection
        let adminRef = db.collection("admins").document("ADM001")
        let adminData: [String: Any] = [
            "name": "Admin User",
            "email": "admin@hospital.com",
            "phoneNo": "+1000000000",
            "lastLogin": Timestamp(date: Date())
        ]
        batch.setData(adminData, forDocument: adminRef)
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("Error initializing database: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Database initialized successfully")
                completion(true, nil)
            }
        }
    }
}