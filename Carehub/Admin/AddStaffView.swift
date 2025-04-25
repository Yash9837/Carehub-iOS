import SwiftUI
struct AddStaffView: View {
    @ObservedObject var staffManager: StaffManager
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var selectedRole: StaffRole = .doctor
    @State private var department = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false

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
                    
                    Button {
                        showImagePicker = true
                    } label: {
                        HStack {
                            Text("Profile Photo")
                            Spacer()
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 24))
                            }
                        }
                    }
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
                
                Section(header: Text("Account Credentials")) {
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
    }
    
    var formIsValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        !phoneNumber.isEmpty &&
        !department.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    private func saveStaff() {
        guard formIsValid else {
            alertMessage = "Please fill all fields with valid information"
            showingAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return
        }
        
        let newStaff = Staff(
            fullName: fullName,
            email: email,
            role: selectedRole,
            department: department,
            phoneNumber: phoneNumber,
            profileImageURL: nil // Will be set after upload
        )
        
        // First upload image if available
        if let image = profileImage {
            // Implement image upload to Firebase Storage
            // Then get the download URL and add to staff object
            // For now, we'll proceed without the image URL
        }
        
        staffManager.addStaff(newStaff, password: password) { success in
            if success {
                dismiss()
            } else {
                alertMessage = staffManager.errorMessage ?? "Failed to add staff"
                showingAlert = true
            }
        }
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
                editForm
            } else {
                detailList
            }
        }
        .navigationTitle(isEditing ? "Edit Staff" : staff.fullName)
        .navigationBarTitleDisplayMode(isEditing ? .inline : .large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Done") {
                        staffManager.updateStaff(staff) { success in
                            if success {
                                isEditing = false
                            } else {
                                print("Failed to update staff.")
                                // You could show an alert here if you want
                            }
                        }
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
                staffManager.deleteStaff(staff) { success in
                    if success {
                        dismiss()
                    } else {
                        print("Failed to delete staff.")
                        // Optional: Set alert states here
                    }
                }
            }

        } message: {
            Text("Are you sure you want to delete \(staff.fullName)? This action cannot be undone.")
        }
    }
    private var editForm: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Full Name", text: $staff.fullName)
                TextField("Email", text: $staff.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
            }

            Section(header: Text("Professional Information")) {
                Picker("Role", selection: $staff.role) {
                    ForEach(StaffRole.allCases) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .disabled(true)

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
    }

    private var detailList: some View {
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
                Text(staff.id!)
                    .font(.system(.body, design: .monospaced))
            }

            Section("Personal Information") {
                InfoRow(label: "Full Name", value: staff.fullName)
                InfoRow(label: "Email", value: staff.email)
                InfoRow(label: "Phone", value: staff.phoneNumber!)
            }

            Section("Professional Information") {
                InfoRow(label: "Role", value: staff.role.rawValue)
                InfoRow(label: "Department", value: staff.department ?? "Cardiac Department")
                InfoRow(label: "Join Date", value: staff.joinDate!.formatted(date: .long, time: .omitted))
            }
        }
        .listStyle(.insetGrouped)
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
