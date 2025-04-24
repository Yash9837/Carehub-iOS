import SwiftUI
import CryptoKit

struct Patient: Codable {
    let fullName: String
    let username: String
    let generatedID: String
    let age: String
    let previousProblems: String
    let allergies: String
    let medications: String
}

struct CareHubTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
            if isSecure {
                SecureField("", text: $text)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .textFieldStyle(PlainTextFieldStyle())
            } else {
                TextField("", text: $text)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .textFieldStyle(PlainTextFieldStyle())
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .frame(height: 40)
    }
}

struct RegisterView: View {
    enum RegistrationStep: Int {
        case credentials = 1
        case age
        case healthInfo
        
        var progress: Double {
            return Double(rawValue) / 3.0
        }
        
        var title: String {
            switch self {
            case .credentials: return "Create Account"
            case .age: return "Your Age"
            case .healthInfo: return "Health Information"
            }
        }
    }
    
    @State private var currentStep: RegistrationStep = .credentials
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var generatedID = ""
    @State private var showPasswordAlert = false
    @State private var previousProblems = ""
    @State private var allergies = ""
    @State private var medications = ""
    @State private var navigateToPatientTab = false
    @State private var navigateToLogin = false
    @State private var patient: Patient?
    @State private var age = ""
    @Environment(\.dismiss) private var dismiss
    
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
                
                VStack {
                    // Progress bar
                    ProgressView(value: currentStep.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.43, green: 0.34, blue: 0.99)))
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    Text("Step \(currentStep.rawValue) of 3")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.top, 5)
                    
                    Text(currentStep.title)
                        .font(.title.bold())
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            switch currentStep {
                            case .credentials:
                                credentialsStep
                            case .age:
                                ageStep
                            case .healthInfo:
                                healthInfoStep
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    // Next/Continue button
                    Button(action: handleNextButton) {
                        Text(currentStep == .healthInfo ? "Complete Registration" : "Continue")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 0.427, green: 0.341, blue: 0.988))
                                    .shadow(radius: 5)
                            )
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if currentStep == .credentials {
                            dismiss()
                        } else {
                            withAnimation {
                                currentStep = RegistrationStep(rawValue: currentStep.rawValue - 1) ?? .credentials
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.blue)
                    }
                }
            }
            .alert("Required Fields Missing", isPresented: $showPasswordAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please fill in all required fields.")
            }
            .navigationDestination(isPresented: $navigateToPatientTab) {
                if let patient = patient {
                    PatientTabView(username: patient.username, patient: patient)
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
    }
    
    private var credentialsStep: some View {
        VStack(spacing: 15) {
            CareHubTextField(text: $name, placeholder: "Full Name", isSecure: false)
                .accessibilityLabel("Full Name")
            
            CareHubTextField(text: $username, placeholder: "Username", isSecure: false)
                .accessibilityLabel("Username")
            
            CareHubTextField(text: $password, placeholder: "Password", isSecure: true)
                .accessibilityLabel("Password")
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.black)
                Button(action: {
                    navigateToLogin = true
                }) {
                    Text("Login")
                        .foregroundColor(.blue)
                        .underline()
                        .fontWeight(.semibold)
                }
                .accessibilityLabel("Login Page Link")
            }
            .padding(.top, 10)
        }
    }
    
    private var ageStep: some View {
        VStack(spacing: 15) {
            CareHubTextField(text: $age, placeholder: "Age", isSecure: false)
                .keyboardType(.numberPad)
                .accessibilityLabel("Age")
        }
    }
    
    private var healthInfoStep: some View {
        VStack(spacing: 15) {
            CareHubTextField(text: $previousProblems, placeholder: "Any Previous Problems (Optional)", isSecure: false)
                .accessibilityLabel("Previous Problems")
            
            CareHubTextField(text: $allergies, placeholder: "Allergies (Optional)", isSecure: false)
                .accessibilityLabel("Allergies")
            
            CareHubTextField(text: $medications, placeholder: "Current Medications (Optional)", isSecure: false)
                .accessibilityLabel("Medications")
        }
    }
    
    private func handleNextButton() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Validate current step before proceeding
        switch currentStep {
        case .credentials:
            if name.trimmingCharacters(in: .whitespaces).isEmpty || password.trimmingCharacters(in: .whitespaces).isEmpty || username.trimmingCharacters(in: .whitespaces).isEmpty {
                showPasswordAlert = true
                return
            }
        case .age:
            if age.trimmingCharacters(in: .whitespaces).isEmpty {
                showPasswordAlert = true
                return
            }
        case .healthInfo:
            break
        }

        if currentStep == .healthInfo {
            generatedID = generateUniqueID(name: name, role: "Patient")
            patient = Patient(
                fullName: name,
                username: username,
                generatedID: generatedID,
                age: age,
                previousProblems: previousProblems,
                allergies: allergies,
                medications: medications
            )
            if let patient = patient, let encoded = try? JSONEncoder().encode(patient) {
                UserDefaults.standard.set(encoded, forKey: "patient")
            }
            
            navigateToPatientTab = true
        } else {
            withAnimation {
                currentStep = RegistrationStep(rawValue: currentStep.rawValue + 1) ?? .credentials
            }
        }
    }
    
    private func generateUniqueID(name: String, role: String) -> String {
        let cleanedName = name.trimmingCharacters(in: .whitespaces).lowercased()
        let cleanedRole = role.trimmingCharacters(in: .whitespaces).lowercased()
        if cleanedName.isEmpty || cleanedRole.isEmpty {
            return ""
        }
        let input = "\(cleanedName)_\(cleanedRole)"
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        let numericHash = Int(hashString.prefix(10), radix: 16) ?? 0
        let sixDigitNumber = String(format: "%06d", numericHash % 1_000_000)
        let rolePrefix = cleanedRole.prefix(1).uppercased()
        return "\(rolePrefix)\(sixDigitNumber)"
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

