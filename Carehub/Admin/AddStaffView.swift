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
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [Color(red: 0.43, green: 0.34, blue: 0.99), Color(red: 0.55, green: 0.48, blue: 0.99)]

    let departments = ["Cardiology", "Neurology", "Pediatrics", "Oncology", "Radiology", "Pathology", "Emergency"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                        Form {
                            Section(header: Text("Personal Information")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)) {
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
                                                .foregroundColor(purpleColor)
                                        }
                                    }
                                }
                            }
                            Section(header: Text("Professional Information")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)) {
                                Picker("Role", selection: $selectedRole) {
                                    ForEach(StaffRole.allCases) { role in
                                        Text(role.rawValue).tag(role)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                Picker("Department", selection: $department) {
                                    ForEach(departments, id: \.self) { dept in
                                        Text(dept).tag(dept)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            Section(header: Text("Account Credentials")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)) {
                                SecureField("Password", text: $password)
                                SecureField("Confirm Password", text: $confirmPassword)
                            }
                        }
                        .background(Color.clear)
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: saveStaff) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .shadow(color: purpleColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(!formIsValid)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Add New Staff")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(purpleColor)
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
            profileImageURL: nil
        )
        
        if let image = profileImage {
            // Implement image upload to Firebase Storage
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


struct StaffDetailView: View {
    @State var staff: Staff
    @ObservedObject var staffManager: StaffManager
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [Color(red: 0.43, green: 0.34, blue: 0.99), Color(red: 0.55, green: 0.48, blue: 0.99)]
    let departments = ["Cardiology", "Neurology", "Pediatrics", "Oncology", "Radiology", "Pathology", "Emergency"]

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
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
                                }
                            }
                        }
                        .foregroundColor(purpleColor)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundColor(purpleColor)
                    }
                }
            }
            .alert("Delete Staff", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    staffManager.deleteStaff(staff) { success in
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(staff.fullName)? This action cannot be undone.")
            }
        }
    }
    
    private var editForm: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 20)
            
            Form {
                Section(header: Text("Personal Information")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)) {
                    TextField("Full Name", text: $staff.fullName)
                    TextField("Email", text: $staff.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Professional Information")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)) {
                    Picker("Role", selection: $staff.role) {
                        ForEach(StaffRole.allCases) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .disabled(true)
                    
                    Picker("Department", selection: $staff.department) {
                        ForEach(departments, id: \.self) { dept in
                            Text(dept).tag(dept)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
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
            .background(Color.clear)
        }
        .padding(.top, 10)
    }
    
    private var detailList: some View {
        VStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        StaffAvatarView(role: staff.role)
                            .frame(width: 100, height: 100)
                        Spacer()
                    }
                }
                .padding()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                VStack(spacing: 10) {
                    InfoRow(label: "Staff ID", value: staff.id ?? "123")
                    InfoRow(label: "Role", value: staff.role.rawValue)
                    InfoRow(label: "Department", value: staff.department ?? "Cardiac Department")
                }
                .padding()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                VStack(spacing: 10) {
                    InfoRow(label: "Full Name", value: staff.fullName)
                    InfoRow(label: "Email", value: staff.email)
                    InfoRow(label: "Phone", value: staff.phoneNumber ?? "123-123-123")
                }
                .padding()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                VStack(spacing: 10) {
                    InfoRow(label: "Join Date", value: staff.joinDate?.formatted(date: .long, time: .omitted) ?? "N/A")
                }
                .padding()
            }
        }
        .padding(.horizontal, 20)
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
                .frame(width: 32, height: 32)
            
            Image(systemName: icon)
                .font(.system(size: 16))
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
