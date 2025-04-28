import FirebaseFirestore
import Combine
import FirebaseAuth

class StaffManager: ObservableObject {
    @Published var staffList: [Staff] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Computed properties
    var doctors: [Staff] { staffList.filter { $0.role == .doctor } }
    var nurses: [Staff] { staffList.filter { $0.role == .nurse } }
    var labTechs: [Staff] { staffList.filter { $0.role == .labTechnician } }
    var admins: [Staff] { staffList.filter { $0.role == .admin } }
    
    private let db = Firestore.firestore()
    
    init() {
        fetchAllStaff()
    }
    
    func fetchAllStaff() {
        isLoading = true
        staffList.removeAll() // Clear existing data to avoid duplication
        errorMessage = nil
        
        let dispatchGroup = DispatchGroup()
        let staffCollections = StaffRole.allCases.map { $0.collectionName }
        
        for collection in staffCollections {
            dispatchGroup.enter()
            // Fetch all fields, filter manually
            db.collection(collection).getDocuments { [weak self] (snapshot, error: Error?) in
                guard let self = self else {
                    dispatchGroup.leave()
                    return
                }
                
                defer { dispatchGroup.leave() } // Ensure leave is called even with errors
                
                if let error = error {
                    self.errorMessage = (self.errorMessage ?? "") + "\nError fetching \(collection): \(error.localizedDescription)"
                    print("Error fetching \(collection): \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found in \(collection)")
                    return
                }
                
                do {
                    let staffMembers = try documents.compactMap { document -> Staff? in
                        let data = document.data()
                        // Map Firestore fields to model fields
                        let fullName = data["Doctor_name"] as? String ?? data["name"] as? String ?? data["fullName"] as? String ?? "Unknown"
                        let email = data["email"] as? String ?? data["Email"] as? String ?? ""
                        let roleString = data["role"] as? String ?? ""
                        let role = StaffRole(rawValue: roleString) ?? .doctor // Default to doctor if unknown
                        let department = data["Filed_name"] as? String ?? data["department"] as? String
                        let phoneNumber = data["phoneNumber"] as? String ?? data["phoneNo"] as? String
                        let joinDate = (data["joinDate"] as? Timestamp)?.dateValue() ?? (data["createdAt"] as? Timestamp)?.dateValue()
                        let profileImageURL = data["imageURL"] as? String ?? data["ImageURL"] as? String ?? ""// Map Firestore imageURL to profileImageURL
                        
                        return Staff(
                            id: document.documentID,
                            fullName: fullName,
                            email: email,
                            role: role,
                            department: department,
                            phoneNumber: phoneNumber,
                            joinDate: joinDate,
                            profileImageURL: profileImageURL
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self.staffList.append(contentsOf: staffMembers)
                        print("Fetched \(staffMembers.count) staff from \(collection)")
                    }
                } catch {
                    self.errorMessage = (self.errorMessage ?? "") + "\nDecoding error in \(collection): \(error.localizedDescription)"
                    print("Decoding error in \(collection): \(error.localizedDescription)")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            if self.staffList.isEmpty && self.errorMessage == nil {
                self.errorMessage = "No staff data found in any collection"
            }
            print("Total staff fetched: \(self.staffList.count)")
        }
    }
    
    func addStaff(_ staff: Staff, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        AuthManager.shared.createStaff(staff: staff, password: password) { [weak self] (success: Bool) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.fetchAllStaff() // Refresh the list after adding
                } else {
                    self.errorMessage = AuthManager.shared.errorMessage ?? "Failed to create staff"
                }
                
                self.isLoading = false
                completion(success)
            }
        }
    }
    
    func updateStaff(_ updatedStaff: Staff, completion: @escaping (Bool) -> Void) {
        guard let id = updatedStaff.id else {
            errorMessage = "Staff ID missing"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try db.collection(updatedStaff.role.collectionName).document(id).setData(from: updatedStaff) { [weak self] error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchAllStaff()
                    completion(true)
                }
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            completion(false)
        }
    }
    
    func deleteStaff(_ staff: Staff, completion: @escaping (Bool) -> Void) {
        guard let id = staff.id else {
            errorMessage = "Staff ID missing"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        self.db.collection(staff.role.collectionName).document(id).delete { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                self.fetchAllStaff()
                completion(true)
            }
        }
    }
}
