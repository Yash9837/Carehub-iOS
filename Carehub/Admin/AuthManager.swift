//
//  AuthManager.swift
//  Carehub
//
//  Created by Yash's Mackbook on 19/04/25.
//


// AuthManager.swift
import Foundation

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var currentStaffMember: Staff?
    
    private init() {
        // Load current user from UserDefaults or keychain in a real app
        self.currentStaffMember = Staff(
            fullName: "Admin User",
            email: "admin@hospital.com",
            role: .admin,
            department: "Administration",
            phoneNumber: "555-1234"
        )
    }
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        // In a real app, you would authenticate with your backend here
        if username.hasPrefix("A") { // Assuming 'A' prefix for admin
            currentStaffMember = Staff(
                fullName: "Admin User",
                email: username,
                role: .admin,
                department: "Administration",
                phoneNumber: "555-1234"
            )
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func logout() {
        currentStaffMember = nil
    }
}