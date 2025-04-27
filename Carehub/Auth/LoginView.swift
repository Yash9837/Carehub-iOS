import SwiftUI
import FirebaseAuth

struct LoginView: View {
    enum Role { case patient, staff }
    
    @State private var selectedRole: Role = .patient // Default to patient
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @StateObject private var authManager = AuthManager.shared
    @State private var navigateToDashboard = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("CareHub")
                        .font(.system(size: 36, weight: .bold))
                    
                    Picker("Login As", selection: $selectedRole) {
                        Text("Patient").tag(Role.patient)
                        Text("Staff").tag(Role.staff)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                    }
                    .padding(.horizontal)
                    
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Login")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    NavigationLink("Don't have an account? Register", destination: RegisterView())
                        .foregroundColor(.purple)
                }
            }
            .navigationDestination(isPresented: $navigateToDashboard) {
                dashboardContent
                .navigationBarBackButtonHidden(true) // Ensure back button is hidden in dashboard
            }
            .alert("Login Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error occurred")
            }
            .onChange(of: authManager.errorMessage) { newValue in
                if let newValue = newValue {
                    errorMessage = newValue
                    showAlert = true
                }
            }
            .navigationBarBackButtonHidden(true) // Hide back button on LoginView
        }
    }
    
    @ViewBuilder
    var dashboardContent: some View {
        if authManager.isLoading {
            ProgressView("Loading dashboard...")
        } else if selectedRole == .patient {
            if let patient = authManager.currentPatient {
                PatientTabView(username: patient.userData.Name, patient: patient)
            } else {
                VStack {
                    Text("No patient data found")
                    Button("Try Again") {
                        authManager.logout()
                    }
                }
            }
        } else if selectedRole == .staff, let staff = authManager.currentStaffMember {
            switch staff.role {
            case .admin:
                AdminTabView()
            case .doctor:
                DoctorTabView()
            case .nurse:
                AdminTabView()
            case .labTechnician:
                LabTechTabView()
            }
        } else {
            VStack {
                Text("No staff data found")
                Button("Try Again") {
                    authManager.logout()
                }
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            showAlert = true
            return
        }
        
        isLoading = true
        
        AuthManager.shared.login(email: email, password: password, role: selectedRole) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    if selectedRole == .patient {
                        if let patient = authManager.currentPatient {
                            self.navigateToDashboard = true
                        } else {
                            self.errorMessage = "Invalid patient credentials"
                            self.showAlert = true
                        }
                    } else if selectedRole == .staff {
                        if let staff = authManager.currentStaffMember {
                            self.navigateToDashboard = true
                        } else {
                            self.errorMessage = "Invalid staff credentials"
                            self.showAlert = true
                        }
                    }
                } else {
                    self.errorMessage = authManager.errorMessage ?? "Login failed"
                    self.showAlert = true
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
