import Firebase
import Foundation

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    // MARK: - Patient Methods

    func patientExists(patientID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        db.collection("patients").document(patientID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(snapshot?.exists ?? false))
        }
    }
    
    func fetchPatientName(patientID: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("patients").document(patientID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let userData = data["userData"] as? [String: Any],
                  let name = userData["Name"] as? String else {
                completion(.failure(NSError(domain: "FirebaseService",
                                            code: 404,
                                            userInfo: [NSLocalizedDescriptionKey: "Patient name not found"])))
                return
            }
            
            completion(.success("\(name)"))
        }
    }


    // MARK: - Vitals Methods

    func fetchPatientVitals(patientID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("patients").document(patientID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let vitals = data["vitals"] as? [String: Any] else {
                completion(.success([:]))
                return
            }
            
            var result: [String: Any] = [:]
            let vitalTypes = ["bp", "weight", "height", "heartRate", "temperature"]
            
            for type in vitalTypes {
                if let history = vitals[type] as? [[String: Any]], let latest = history.last {
                    result[type] = latest["value"] ?? ""
                    
                    let transformedHistory: [[String: Any]] = history.compactMap { entry in
                        guard let value = entry["value"],
                              let timestamp = entry["timestamp"] as? Timestamp else {
                            return nil
                        }
                        return [
                            "value": value,
                            "timestamp": timestamp.dateValue()
                        ]
                    }
                    result["\(type)History"] = transformedHistory
                }
            }
            
            if let allergies = vitals["allergies"] as? [String] {
                result["allergies"] = allergies.joined(separator: ", ")
            }
            
            completion(.success(result))
        }
    }


    func savePatientVitals(patientID: String, vitals: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = db.collection("patients").document(patientID)
        let timestamp = Timestamp(date: Date())
        
        documentRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var updates: [String: Any] = [:]
            var currentVitals = snapshot?.data()?["vitals"] as? [String: Any] ?? [:]
            let vitalTypes = ["bp", "weight", "height", "heartRate", "temperature"]
            
            for type in vitalTypes {
                if let value = vitals[type] {
                    let valueStr = "\(value)"
                    if !valueStr.trimmingCharacters(in: .whitespaces).isEmpty {
                        var history = currentVitals[type] as? [[String: Any]] ?? []
                        history.append([
                            "value": value,
                            "timestamp": timestamp
                        ])
                        updates[type] = history
                    }
                }
            }
            
            if let allergyString = vitals["allergies"] as? String {
                let allergyArray = allergyString
                    .components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                
                if !allergyArray.isEmpty {
                    updates["allergies"] = allergyArray
                }
            }
            
            let vitalsUpdate: [String: Any] = [
                "vitals": updates,
                "lastModified": Timestamp(date: Date())
            ]
            
            documentRef.setData(vitalsUpdate, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    func fetchVitalTrends(patientID: String, vitalType: String, completion: @escaping (Result<[(String, Date)], Error>) -> Void) {
        db.collection("patients").document(patientID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let vitals = data["vitals"] as? [String: Any],
                  let history = vitals[vitalType] as? [[String: Any]] else {
                completion(.success([]))
                return
            }
            
            let trendData = history.compactMap { entry -> (String, Date)? in
                guard let value = entry["value"] as? String,
                      let timestamp = entry["timestamp"] as? Timestamp else {
                    return nil
                }
                return (value, timestamp.dateValue())
            }
            
            completion(.success(trendData))
        }
    }
    
    func fetchNurse(byId nurseId: String, completion: @escaping (Result<Nurse, Error>) -> Void) {
        db.collection("nurses").document(nurseId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let nurse = Nurse(from: data) else {
                completion(.failure(NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Nurse not found or data is invalid."])))
                return
            }

            completion(.success(nurse))
        }
    }
}

class NurseViewModel: ObservableObject {
    @Published var nurse: Nurse?
    @Published var isLoading = false
    @Published var error: Error?

    func fetchNurse(byNurseId nurseId: String) {
        isLoading = true
        error = nil

        FirebaseService.shared.fetchNurse(byId: nurseId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let nurse):
                    self.nurse = nurse
                case .failure(let err):
                    self.error = err
                }
            }
        }
    }
}
