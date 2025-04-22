import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Patient Records Operations
    
    func fetchPatients(completion: @escaping ([PatientInfo]?, Error?) -> Void) {
        db.collection("patients").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let patients = snapshot?.documents.compactMap { document in
                try? document.data(as: PatientInfo.self)
            }
            completion(patients, nil)
        }
    }
    
    func fetchTestResults(forPatientId patientId: String, completion: @escaping ([TestResult]?, Error?) -> Void) {
        let collection = db.collection("medicalTests")
        
        if patientId.isEmpty {
            // Fetch all test results
            collection.getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let testResults = snapshot?.documents.compactMap { document in
                    try? document.data(as: TestResult.self)
                }
                completion(testResults, nil)
            }
        } else {
            // Fetch test results for a specific patient
            collection.whereField("patientId", isEqualTo: patientId).getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let testResults = snapshot?.documents.compactMap { document in
                    try? document.data(as: TestResult.self)
                }
                completion(testResults, nil)
            }
        }
    }
    
    // MARK: - Add/Update Operations
    
    func addPatient(_ patient: PatientInfo, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("patients").document(patient.generatedID).setData(from: patient, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func addTestResult(_ testResult: TestResult, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("medicalTests").document(testResult.id).setData(from: testResult, completion: completion)
        } catch {
            completion(error)
        }
    }
}
