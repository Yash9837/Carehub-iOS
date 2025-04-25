import SwiftUI
<<<<<<< Updated upstream
<<<<<<< Updated upstream

enum Role {
    case patient
    case staff
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .natural
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.backgroundColor = .white
        textField.isSecureTextEntry = isSecure
        updatePlaceholder(textField)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.textColor = .black
        uiView.layer.borderColor = UIColor.lightGray.cgColor
        uiView.layer.borderWidth = 1.0
        uiView.backgroundColor = .white
        uiView.isSecureTextEntry = isSecure
        updatePlaceholder(uiView)
    }

    private func updatePlaceholder(_ textField: UITextField) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
            textField.textColor = .black
            textField.backgroundColor = .white
        }
    }
}
=======
import FirebaseAuth
>>>>>>> Stashed changes
=======
import FirebaseAuth
>>>>>>> Stashed changes

struct LoginView: View {
    enum Role { case patient, staff }
    
    @State private var selectedRole: Role = .patient // Default to patient
    @State private var email: String = ""
    @State private var password: String = ""
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    @State private var navigateToTab = false
    @State private var tabDestination: AnyView?
    @State private var showInvalidStaffAlert = false
    @State private var showEmptyFieldsAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                LinearGradient(
                    colors: [
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4),
                        Color.white.opacity(0.9),
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                LoginFormView(
                    selectedRole: $selectedRole,
                    username: $username,
                    password: $password,
                    animateButtons: $animateButtons,
                    showRegister: $showRegister,
                    loginAction: {
                        if username.isEmpty || password.isEmpty {
                            showEmptyFieldsAlert = true
                            return
                        }
                        switch selectedRole {
                        case .patient:
                            if let storedData = UserDefaults.standard.data(forKey: "patientF"),
                               let storedPatient = try? JSONDecoder().decode(PatientF.self, from: storedData),
                               storedPatient.username == username,
                               storedPatient.userData.Password == password {
                                tabDestination = AnyView(PatientTabView(username: username, patient: storedPatient))
                                navigateToTab = true
                            } else {
                                // Create a temporary patient for navigation (for testing purposes)
                                let patient = PatientF(
                                    emergencyContact: [],
                                    medicalRecords: [],
                                    testResults: [],
                                    userData: UserData(
                                        Address: "123 Main St",
                                        Dob: "01/01/1990",
                                        Email: "\(username)@example.com",
                                        Name: username,
                                        Password: password,
                                        aadharNo: "",
                                        phoneNo: "1234567890"
                                    ),
                                    vitals: Vitals(
                                        allergies: [],
                                        bp: [],
                                        heartRate: [],
                                        height: [],
                                        temperature: [],
                                        weight: []
                                    ),
                                    lastModified: Date(),
                                    patientId: "P000000",
                                    username: username
                                )
                                tabDestination = AnyView(PatientTabView(username: username, patient: patient))
                                navigateToTab = true
                            }
                        case .staff:
                            AuthManager.shared.login(username: username, password: password) { success in
                                if success {
                                    if username.uppercased().hasPrefix("D") {
                                        tabDestination = AnyView(DoctorTabView())
                                    } else if username.uppercased().hasPrefix("A") {
                                        tabDestination = AnyView(AdminTabView())
                                    } else {
                                        showInvalidStaffAlert = true
                                        return
                                    }
                                    navigateToTab = true
                                } else {
                                    showInvalidStaffAlert = true
                                }
                            }
=======
    @State private var showAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @StateObject private var authManager = AuthManager.shared
    @State private var navigateToDashboard = false
    
    var body: some View {
        NavigationStack {
            ZStack {
=======
    @State private var showAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @StateObject private var authManager = AuthManager.shared
    @State private var navigateToDashboard = false
    
    var body: some View {
        NavigationStack {
            ZStack {
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
            }
            .alert("Login Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
<<<<<<< Updated upstream
            } message: {
                Text(errorMessage ?? "Unknown error occurred")
            }
<<<<<<< Updated upstream
            .alert("Empty Fields", isPresented: $showEmptyFieldsAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please fill in both username and password.")
            }
        }
    }
}

struct LoginFormView: View {
    @Binding var selectedRole: Role
    @Binding var username: String
    @Binding var password: String
    @Binding var animateButtons: Bool
    @Binding var showRegister: Bool
    let loginAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("CareHub")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 40)
                .shadow(radius: 2)

            Text("Login to Your Account")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .foregroundColor(.black)

            Picker("Select Role", selection: $selectedRole) {
                Text("Patient").tag(Role.patient)
                Text("Staff").tag(Role.staff)
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.8))
            .padding(.horizontal, 20)

            VStack(spacing: 15) {
                CustomTextField(text: $username, placeholder: "Username or Email")
                    .frame(height: 40)
                    .padding(.horizontal, 20)

                CustomTextField(text: $password, placeholder: "Password", isSecure: true)
                    .frame(height: 40)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)

            LoginButton(
                title: "Login",
                color: Color(red: 0.427, green: 0.341, blue: 0.988),
                icon: "arrow.right.circle.fill",
                animate: animateButtons,
                action: loginAction
            )

            HStack {
                Text("If you don't have an account, then ")
                    .foregroundColor(.black)
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showRegister = true
                }) {
                    Text("Register")
                        .foregroundColor(.blue)
                        .underline()
                        .fontWeight(.semibold)
=======
=======
            } message: {
                Text(errorMessage ?? "Unknown error occurred")
            }
>>>>>>> Stashed changes
            .onChange(of: authManager.errorMessage) { newValue in
                if let newValue = newValue {
                    errorMessage = newValue
                    showAlert = true
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                }
            }
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
<<<<<<< Updated upstream
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
<<<<<<< Updated upstream
        .scaleEffect(animate ? 1 : 0.9)
        .opacity(animate ? 1 : 0)
=======
=======
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
>>>>>>> Stashed changes
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            showAlert = true
            return
        }
        
        isLoading = true
        
        AuthManager.shared.login(email: email, password: password) { success in
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
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

//// Placeholder for AuthManager
//class AuthManager {
//    static let shared = AuthManager()
//
//    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
//        if username.uppercased().hasPrefix("D") || username.uppercased().hasPrefix("A") {
//            completion(true)
//        } else {
//            completion(false)
//        }
//    }
//}
