//
//  AddStaffView.swift
//  Carehub
//
//  Created by Yash's Mackbook on 19/04/25.
//
import SwiftUI

// AddStaffView.swift
struct AddStaffView: View {
    @ObservedObject var staffManager: StaffManager
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var selectedRole: StaffRole = .doctor
    @State private var department = ""
    @State private var phoneNumber = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let departments = ["Cardiology", "Neurology", "Pediatrics", "Oncology", "Radiology", "Pathology", "Emergency"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Professional Information")) {
                    Picker("Role", selection: $selectedRole) {
                        ForEach(StaffRole.allCases) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    
                    Picker("Department", selection: $department) {
                        ForEach(departments, id: \.self) { dept in
                            Text(dept).tag(dept)
                        }
                    }
                }
            }
            .navigationTitle("Add New Staff")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStaff()
                    }
                    .disabled(!formIsValid)
                }
            }
            .alert("Validation Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    var formIsValid: Bool {
        !fullName.isEmpty && 
        !email.isEmpty && 
        email.contains("@") && 
        !phoneNumber.isEmpty && 
        !department.isEmpty
    }
    
    private func saveStaff() {
        guard formIsValid else {
            alertMessage = "Please fill all fields with valid information"
            showingAlert = true
            return
        }
        
        let newStaff = Staff(
            fullName: fullName,
            email: email,
            role: selectedRole,
            department: department,
            phoneNumber: phoneNumber
        )
        
        staffManager.addStaff(newStaff)
        dismiss()
    }
}

// StaffDetailView.swift
struct StaffDetailView: View {
    @State var staff: Staff
    @ObservedObject var staffManager: StaffManager
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    let departments = ["Cardiology", "Neurology", "Pediatrics", "Oncology", "Radiology", "Pathology", "Emergency"]
    
    var body: some View {
        Group {
            if isEditing {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("Full Name", text: $staff.fullName)
                        TextField("Email", text: $staff.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Phone Number", text: $staff.phoneNumber)
                            .keyboardType(.phonePad)
                    }
                    
                    Section(header: Text("Professional Information")) {
                        Picker("Role", selection: $staff.role) {
                            ForEach(StaffRole.allCases) { role in
                                Text(role.rawValue).tag(role)
                            }
                        }
                        .disabled(true) // Role shouldn't be changed as it affects ID
                        
                        Picker("Department", selection: $staff.department) {
                            ForEach(departments, id: \.self) { dept in
                                Text(dept).tag(dept)
                            }
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Staff", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            } else {
                List {
                    Section {
                        HStack {
                            Spacer()
                            StaffAvatarView(role: staff.role)
                                .frame(width: 100, height: 100)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                    
                    Section("Staff ID") {
                        Text(staff.id)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    Section("Personal Information") {
                        InfoRow(label: "Full Name", value: staff.fullName)
                        InfoRow(label: "Email", value: staff.email)
                        InfoRow(label: "Phone", value: staff.phoneNumber)
                    }
                    
                    Section("Professional Information") {
                        InfoRow(label: "Role", value: staff.role.rawValue)
                        InfoRow(label: "Department", value: staff.department)
                        InfoRow(label: "Join Date", value: staff.joinDate.formatted(date: .long, time: .omitted))
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(isEditing ? "Edit Staff" : staff.fullName)
        .navigationBarTitleDisplayMode(isEditing ? .inline : .large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Done") {
                        staffManager.updateStaff(staff)
                        isEditing = false
                    }
                } else {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
        .alert("Delete Staff", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                staffManager.deleteStaff(staff)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \(staff.fullName)? This action cannot be undone.")
        }
    }
}

// StaffAvatarView.swift
struct StaffAvatarView: View {
    let role: StaffRole
    
    var color: Color {
        switch role {
        case .doctor: return .green
        case .nurse: return .orange
        case .labTechnician: return .purple
        case .admin: return .blue
        }
    }
    
    var icon: String {
        switch role {
        case .doctor: return "stethoscope"
        case .nurse: return "cross.case.fill"
        case .labTechnician: return "testtube.2"
        case .admin: return "person.fill"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 100, height: 100)
            
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
        }
    }
}

// InfoRow.swift
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}
