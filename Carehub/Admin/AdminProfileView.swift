// AdminProfileView.swift
import SwiftUI

struct AdminProfileView: View {
    @State private var admin: Staff
    @State private var isEditing = false
    @State private var tempName: String
    @State private var tempEmail: String
    @State private var tempPhone: String
    
    init(admin: Staff) {
        self._admin = State(initialValue: admin)
        self._tempName = State(initialValue: admin.fullName)
        self._tempEmail = State(initialValue: admin.email)
        self._tempPhone = State(initialValue: admin.phoneNumber)
    }
    
    var body: some View {
        Group {
            if isEditing {
                editProfileView
            } else {
                profileView
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Done") {
                        saveChanges()
                        isEditing = false
                    }
                } else {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
    }
    
    private var profileView: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    StaffAvatarView(role: admin.role)
                        .frame(width: 100, height: 100)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            Section("Admin Information") {
                InfoRow(label: "Staff ID", value: admin.id)
                InfoRow(label: "Role", value: admin.role.rawValue)
                InfoRow(label: "Department", value: admin.department)
            }
            
            Section("Personal Information") {
                InfoRow(label: "Full Name", value: admin.fullName)
                InfoRow(label: "Email", value: admin.email)
                InfoRow(label: "Phone", value: admin.phoneNumber)
            }
            
            Section("Account") {
                Button(role: .destructive) {
                    // Handle password change
                } label: {
                    Text("Change Password")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var editProfileView: some View {
        Form {
            Section("Personal Information") {
                TextField("Full Name", text: $tempName)
                TextField("Email", text: $tempEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                TextField("Phone Number", text: $tempPhone)
                    .keyboardType(.phonePad)
            }
            
            Section {
                Button(role: .destructive) {
                    isEditing = false
                    resetTempValues()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func saveChanges() {
        admin.fullName = tempName
        admin.email = tempEmail
        admin.phoneNumber = tempPhone
        // Here you would typically save to your database/backend
    }
    
    private func resetTempValues() {
        tempName = admin.fullName
        tempEmail = admin.email
        tempPhone = admin.phoneNumber
    }
}

// Preview Provider
struct AdminProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AdminProfileView(admin: Staff(
                fullName: "Admin User",
                email: "admin@hospital.com",
                role: .admin,
                department: "Administration",
                phoneNumber: "555-1234"
            ))
        }
    }
}