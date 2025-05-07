import SwiftUI

struct AdminProfileView: View {
    @State private var admin: Staff
    @State private var isEditing = false
    @State private var tempName: String
    @State private var tempEmail: String
    @State private var tempPhone: String
    @State private var showLoginView = false // State to trigger navigation to LoginView
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    private let gradientColors = [Color(red: 0.43, green: 0.34, blue: 0.99), Color(red: 0.55, green: 0.48, blue: 0.99)]
    
    init(admin: Staff) {
        self._admin = State(initialValue: admin)
        self._tempName = State(initialValue: admin.fullName)
        self._tempEmail = State(initialValue: admin.email)
        self._tempPhone = State(initialValue: admin.phoneNumber ?? "12345")
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
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
                        .foregroundColor(purpleColor)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundColor(purpleColor)
                    }
                }
            }
            // Full-screen cover for LoginView
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView() // Replace with your actual LoginView
            }
        }
    }
    
    private var profileView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar Section with Gradient Background
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 150)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    VStack {
                        StaffAvatarView(role: admin.role)
                            .frame(width: 80, height: 80)
                        Text(admin.fullName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 20)
                
                // Staff Info Section
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    VStack(spacing: 12) {
                        InfoRow(label: "Staff ID", value: admin.id ?? "123")
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        InfoRow(label: "Role", value: admin.role.rawValue)
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        InfoRow(label: "Department", value: admin.department ?? "N/A")
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
                
                // Contact Info Section
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    VStack(spacing: 12) {
                        InfoRow(label: "Full Name", value: admin.fullName)
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        InfoRow(label: "Email", value: admin.email)
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        InfoRow(label: "Phone", value: admin.phoneNumber ?? "123456")
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
                
                // Action Button Section
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    VStack(spacing: 12) {
                        Button(action: {
                            AuthManager.shared.logout()
                            showLoginView = true
                        }) {
                            Text("Logout")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var editProfileView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 20)
            
            Form {
                Section(header: Text("Personal Information")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)) {
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
            .background(Color.clear)
        }
        .padding(.top, 10)
    }
    
    private func saveChanges() {
        admin.fullName = tempName
        admin.email = tempEmail
        admin.phoneNumber = tempPhone
    }
    
    private func resetTempValues() {
        tempName = admin.fullName
        tempEmail = admin.email
        tempPhone = admin.phoneNumber ?? "12345"
    }
}
