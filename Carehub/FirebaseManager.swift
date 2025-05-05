import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Patient Records Operations
    
    func fetchPatients(completion: @escaping ([PatientInfo]?, Error?) -> Void) {
        print("Fetching patients...")
        db.collection("patients").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching patients: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No patient documents found")
                completion([], nil)
                return
            }
            
            let patients = documents.compactMap { document -> PatientInfo? in
                do {
                    let patient = try document.data(as: PatientInfo.self)
                    return patient
                } catch {
                    print("Error decoding patient \(document.documentID): \(error)")
                    return nil
                }
            }
            print("Fetched \(patients.count) patients: \(patients.map { $0.generatedID })")
            completion(patients, nil)
        }
    }
    
    func fetchTestResults(forPatientId patientId: String, completion: @escaping ([TestResult]?, Error?) -> Void) {
        let collection = db.collection("medicalTests")
        
        print("Fetching test results for patientId: \(patientId)")
        
        if patientId.isEmpty {
            // Fetch all test results
            collection.getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching all test results: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No test result documents found")
                    completion([], nil)
                    return
                }
                
                let testResults = documents.compactMap { document -> TestResult? in
                    do {
                        let result = try document.data(as: TestResult.self)
                        return result
                    } catch {
                        print("Error decoding test result \(document.documentID): \(error)")
                        return nil
                    }
                }
                print("Fetched \(testResults.count) test results: \(testResults.map { $0.id })")
                completion(testResults, nil)
            }
        } else {
            // Fetch test results for a specific patient
            collection.whereField("patientId", isEqualTo: patientId).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching test results for patient \(patientId): \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No test results found for patientId: \(patientId)")
                    completion([], nil)
                    return
                }
                
                let testResults = documents.compactMap { document -> TestResult? in
                    do {
                        let result = try document.data(as: TestResult.self)
                        return result
                    } catch {
                        print("Error decoding test result \(document.documentID): \(error)")
                        return nil
                    }
                }
                print("Fetched \(testResults.count) test results for patientId \(patientId): \(testResults.map { $0.id })")
                completion(testResults, nil)
            }
        }
    }
    
    // MARK: - Add/Update Operations
    
    func addPatient(_ patient: PatientInfo, completion: @escaping (Error?) -> Void) {
        do {
            print("Adding patient with ID: \(patient.generatedID)")
            try db.collection("patients").document(patient.generatedID).setData(from: patient, completion: { error in
                if let error = error {
                    print("Error adding patient: \(error.localizedDescription)")
                } else {
                    print("Successfully added patient: \(patient.generatedID)")
                }
                completion(error)
            })
        } catch {
            print("Error encoding patient: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    func addTestResult(_ testResult: TestResult, completion: @escaping (Error?) -> Void) {
        do {
            print("Adding test result with ID: \(testResult.id)")
            try db.collection("medicalTests").document(testResult.id).setData(from: testResult, completion: { error in
                if let error = error {
                    print("Error adding test result: \(error.localizedDescription)")
                } else {
                    print("Successfully added test result: \(testResult.id)")
                }
                completion(error)
            })
        } catch {
            print("Error encoding test result: \(error.localizedDescription)")
            completion(error)
        }
    }
}
