
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
        staffList = []
        
        let staffCollections = StaffRole.allCases.map { $0.collectionName }
        
        for collection in staffCollections {
            db.collection(collection).getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                do {
                    let staffMembers = try documents.compactMap { document -> Staff? in
                        var staff = try document.data(as: Staff.self)
                        staff.id = document.documentID
                        return staff
                    }
                    
                    DispatchQueue.main.async {
                        self.staffList.append(contentsOf: staffMembers)
                        self.isLoading = false
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
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
    // In AuthManager.swift
   
    
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
        
        // First delete from authentication
        Auth.auth().currentUser?.delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            // Then delete from Firestore
            self.db.collection(staff.role.collectionName).document(id).delete { error in
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
}
