import SwiftUI
import CryptoKit

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
                SecureField(placeholder, text: $text)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .textFieldStyle(PlainTextFieldStyle())
            } else {
                TextField(placeholder, text: $text)
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
        case personalInfo
        case contactInfo
        case healthInfo
        
        var progress: Double {
            return Double(rawValue) / 4.0
        }
        
        var title: String {
            switch self {
            case .credentials: return "Create Account"
            case .personalInfo: return "Personal Information"
            case .contactInfo: return "Contact Information"
            case .healthInfo: return "Health Information"
            }
        }
    }
    
    @State private var currentStep: RegistrationStep = .credentials
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var dob = ""
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var phoneNo = ""
    @State private var address = ""
    @State private var aadharNo = ""
    @State private var emergencyContacts: [EmergencyContact] = []
    @State private var newContactName = ""
    @State private var newContactNumber = ""
    @State private var previousProblems = ""
    @State private var allergies = ""
    @State private var medications = ""
    @State private var generatedID = ""
    @State private var showAlert = false
    @State private var navigateToPatientTab = false
    @State private var navigateToLogin = false
    @State private var patient: PatientF?
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
                    ProgressView(value: currentStep.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.43, green: 0.34, blue: 0.99)))
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    Text("Step \(currentStep.rawValue) of 4")
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
                            case .personalInfo:
                                personalInfoStep
                            case .contactInfo:
                                contactInfoStep
                            case .healthInfo:
                                healthInfoStep
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
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
            .alert("Required Fields Missing", isPresented: $showAlert) {
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
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("Select Date of Birth", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                    
                    Button(action: {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        dob = dateFormatter.string(from: selectedDate)
                        showDatePicker = false
                    }) {
                        Text("Done")
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
        }
    }
    
    private var credentialsStep: some View {
        VStack(spacing: 15) {
            CareHubTextField(text: $fullName, placeholder: "Full Name", isSecure: false)
                .accessibilityLabel("Full Name")
            
            CareHubTextField(text: $username, placeholder: "Username", isSecure: false)
                .accessibilityLabel("Username")
            
            CareHubTextField(text: $email, placeholder: "Email", isSecure: false)
                .accessibilityLabel("Email")
            
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
    
    private var personalInfoStep: some View {
        VStack(spacing: 15) {
            Button(action: { showDatePicker = true }) {
                ZStack(alignment: .leading) {
                    if dob.isEmpty {
                        Text("Date of Birth (Tap to Select)")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                    }
                    Text(dob.isEmpty ? "" : dob)
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .accessibilityLabel("Date of Birth")
        }
    }
    
    private var contactInfoStep: some View {
        VStack(spacing: 15) {
            CareHubTextField(text: $phoneNo, placeholder: "Phone Number", isSecure: false)
                .keyboardType(.phonePad)
                .accessibilityLabel("Phone Number")
            
            CareHubTextField(text: $address, placeholder: "Address", isSecure: false)
                .accessibilityLabel("Address")
            
            CareHubTextField(text: $aadharNo, placeholder: "Aadhar Number (Optional)", isSecure: false)
                .keyboardType(.numberPad)
                .accessibilityLabel("Aadhar Number")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Emergency Contacts")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                ForEach(emergencyContacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            TextField("Name", text: .constant(contact.name))
                                .font(.system(size: 16))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(true)
                            
                            TextField("Number", text: .constant(contact.Number))
                                .font(.system(size: 16))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(true)
                        }
                        
                        Button(action: {
                            withAnimation {
                                emergencyContacts.removeAll { $0.id == contact.id }
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 22))
                        }
                        .padding(.trailing, 8)
                    }
                }
                
                CareHubTextField(text: $newContactName, placeholder: "New Contact Name", isSecure: false)
                    .accessibilityLabel("New Contact Name")
                
                CareHubTextField(text: $newContactNumber, placeholder: "New Contact Number", isSecure: false)
                    .keyboardType(.phonePad)
                    .accessibilityLabel("New Contact Number")
                
                Button(action: {
                    if !newContactName.isEmpty && !newContactNumber.isEmpty {
                        withAnimation {
                            emergencyContacts.append(EmergencyContact(Number: newContactNumber, name: newContactName))
                            newContactName = ""
                            newContactNumber = ""
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Contact")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
            }
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
    
    private func calculateAge(from dob: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let birthDate = dateFormatter.date(from: dob) else { return nil }
        
        let currentDate = DateComponents(year: 2025, month: 4, day: 24).date!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        return components.year
    }
    
    private func handleNextButton() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        switch currentStep {
        case .credentials:
            if fullName.trimmingCharacters(in: .whitespaces).isEmpty ||
               username.trimmingCharacters(in: .whitespaces).isEmpty ||
               email.trimmingCharacters(in: .whitespaces).isEmpty ||
               password.trimmingCharacters(in: .whitespaces).isEmpty {
                showAlert = true
                return
            }
        case .personalInfo:
            if dob.trimmingCharacters(in: .whitespaces).isEmpty {
                showAlert = true
                return
            }
        case .contactInfo:
            if phoneNo.trimmingCharacters(in: .whitespaces).isEmpty ||
               address.trimmingCharacters(in: .whitespaces).isEmpty {
                showAlert = true
                return
            }
        case .healthInfo:
            break
        }

        if currentStep == .healthInfo {
            generatedID = generateUniqueID(name: fullName, role: "Patient")
            patient = PatientF(
                emergencyContact: emergencyContacts,
                medicalRecords: [],
                testResults: [],
                userData: UserData(
                    Address: address,
                    Dob: dob,
                    Email: email,
                    Name: fullName,
                    Password: password,
                    aadharNo: aadharNo,
                    phoneNo: phoneNo
                ),
                vitals: Vitals(
                    allergies: allergies.isEmpty ? [] : allergies.components(separatedBy: ", "),
                    bp: [],
                    heartRate: [],
                    height: [],
                    temperature: [],
                    weight: []
                ),
                lastModified: Date(),
                patientId: generatedID,
                username: username
            )
            if let patient = patient, let encoded = try? JSONEncoder().encode(patient) {
                UserDefaults.standard.set(encoded, forKey: "patientF")
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
