import SwiftUI
import FirebaseFirestore

struct Accountant: Identifiable, Codable {
    var id: String { accountantId }
    var email: String
    var name: String
    var password: String?  // Include but mark as optional since we may not want to expose this
    var shift: Shift
    var accountantId: String
    var createdAt: Timestamp?  // Using Firestore Timestamp
    var phoneNo: String
    
    struct Shift: Codable {
        var endTime: String
        var startTime: String
    }
    
    // Ensuring exact field names from the database
    enum CodingKeys: String, CodingKey {
        case email = "Email"
        case name = "Name"
        case password = "Password"
        case shift = "Shift"
        case accountantId = "accountantId"
        case createdAt = "createdAt"
        case phoneNo = "phoneNo"
    }
}

class AccountantViewModel: ObservableObject {
    @Published var accountant: Accountant?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchAccountant(byAccountantId accountantId: String) {
        isLoading = true
        error = nil
        
        // Directly access the document using the ID
        db.collection("accountants").document(accountantId)
            .getDocument { [weak self] document, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.error = error
                        print("Error fetching accountant: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = document, document.exists, let data = document.data() else {
                        self?.error = NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Accountant not found"])
                        return
                    }
                    
                    // Manual construction of Accountant object from document data
                    do {
                        // Extract shift data
                        guard let shiftData = data["Shift"] as? [String: String],
                              let endTime = shiftData["endTime"],
                              let startTime = shiftData["startTime"] else {
                            throw NSError(domain: "ParsingError", code: 400,
                                   userInfo: [NSLocalizedDescriptionKey: "Failed to parse shift data"])
                        }
                        
                        let shift = Accountant.Shift(endTime: endTime, startTime: startTime)
                        
                        // Create accountant object
                        let accountant = Accountant(
                            email: data["Email"] as? String ?? "",
                            name: data["Name"] as? String ?? "",
                            password: data["Password"] as? String,
                            shift: shift,
                            accountantId: data["accountantId"] as? String ?? accountantId, // Default to document ID if not present
                            createdAt: data["createdAt"] as? Timestamp,
                            phoneNo: data["phoneNo"] as? String ?? ""
                        )
                        
                        self?.accountant = accountant
                    } catch {
                        self?.error = error
                        print("Error decoding accountant: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    // Update accountant's shift hours
    func updateShiftHours(accountantId: String, newStart: String, newEnd: String) {
        db.collection("accountants").document(accountantId)
            .updateData([
                "Shift.startTime": newStart,
                "Shift.endTime": newEnd
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating shift: \(error.localizedDescription)")
                } else {
                    print("Shift updated successfully")
                    // Refresh the data
                    self?.fetchAccountant(byAccountantId: accountantId)
                }
            }
    }
}
