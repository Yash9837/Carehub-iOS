import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import AVFoundation // For text-to-speech

struct ProfileView_patient: View {
    let patient: PatientF
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToLogin = false
    @AppStorage("isLargeFontEnabled") private var isLargeFontEnabled = false
    @AppStorage("isVoiceOverEnabled") private var isVoiceOverEnabled = false // New toggle for VoiceOver
    @State private var speechSynthesizer = AVSpeechSynthesizer() // Speech synthesizer instance
    @State private var isInitialLoad = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 16) {
                        // Accessibility Section with Toggles
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Accessibility")
                                .font(FontSizeManager.font(for: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)

                            Toggle(isOn: $isLargeFontEnabled) {
                                Label("Large Font Size", systemImage: "textformat.size")
                                    .font(FontSizeManager.font(for: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                            )

                            Toggle(isOn: $isVoiceOverEnabled) {
                                Label("VoiceOver (Read Aloud)", systemImage: "speaker.wave.2.fill")
                                    .font(FontSizeManager.font(for: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                            )
                            .onChange(of: isVoiceOverEnabled) { newValue in
                                if newValue {
                                    readProfileText()
                                } else {
                                    speechSynthesizer.stopSpeaking(at: .immediate)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        // Profile Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Profile")
                                .font(FontSizeManager.font(for: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)

                            HStack(spacing: 16) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.43, green: 0.34, blue: 0.99),
                                                Color(red: 0.55, green: 0.48, blue: 0.99)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 5, x: 0, y: 3)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(patient.userData.Name)
                                        .font(FontSizeManager.font(for: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        // Personal Information
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Personal Information")
                                .font(FontSizeManager.font(for: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            ProfileRow(title: "Patient ID", value: patient.patientId, icon: "person.text.rectangle.fill")
                            ProfileRow(title: "Date of Birth", value: patient.userData.Dob, icon: "calendar")
                            ProfileRow(title: "Email", value: patient.userData.Email, icon: "envelope.fill")
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        // Contact Information
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contact Information")
                                .font(FontSizeManager.font(for: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            ProfileRow(title: "Phone Number", value: patient.userData.phoneNo, icon: "phone.fill")
                            ProfileRow(title: "Address", value: patient.userData.Address, icon: "house.fill")
                            ProfileRow(title: "Aadhar Number", value: patient.userData.aadharNo.isEmpty ? "Not Provided" : patient.userData.aadharNo, icon: "person.text.rectangle")
                            
                            MultiItemProfileRow(
                                title: "Emergency Contacts",
                                value: patient.emergencyContact.map { "\($0.name) (\($0.Number))" }.joined(separator: ", "),
                                icon: "person.fill"
                            )
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        // Medical Information
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Information")
                                .font(FontSizeManager.font(for: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                .padding(.horizontal, 16)
                            
                            MultiItemProfileRow(
                                title: "Allergies",
                                value: patient.vitals.allergies.joined(separator: ", "),
                                icon: "allergens"
                            )
                            
                            ProfileRow(
                                title: "Latest Blood Pressure",
                                value: patient.vitals.bp.last?.value ?? "Not Recorded",
                                icon: "heart.fill"
                            )
                            
                            ProfileRow(
                                title: "Latest Heart Rate",
                                value: patient.vitals.heartRate.last?.value ?? "Not Recorded",
                                icon: "heart.fill"
                            )
                            
                            ProfileRow(
                                title: "Latest Height",
                                value: patient.vitals.height.last?.value ?? "Not Recorded",
                                icon: "ruler"
                            )
                            
                            ProfileRow(
                                title: "Latest Temperature",
                                value: patient.vitals.temperature.last?.value ?? "Not Recorded",
                                icon: "thermometer"
                            )
                            
                            ProfileRow(
                                title: "Latest Weight",
                                value: patient.vitals.weight.last?.value ?? "Not Recorded",
                                icon: "scalemass"
                            )
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        // Sign Out Button
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                AuthManager.shared.logout()
                                navigateToLogin = true
                            }) {
                                Label("Sign Out", systemImage: "arrow.right.circle")
                                    .font(FontSizeManager.font(for: 16, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: EditProfileView(patient: patient)) {
                            Text("Edit")
                                .font(FontSizeManager.font(for: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        }
                    }
                }
                .fullScreenCover(isPresented: $navigateToLogin) {
                    LoginView()
                }
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            if isVoiceOverEnabled {
                readProfileText()
            }
        }
        .onAppear {
                    if isInitialLoad {
                        isInitialLoad = false // Mark initial load as complete
                    } else if isVoiceOverEnabled {
                        readProfileText() // Only read if not initial load and VoiceOver is enabled
                    }
                }
        .onDisappear {
                    speechSynthesizer.stopSpeaking(at: .immediate) // Stop speech when leaving the view
                }
    }

    private func readProfileText() {
        let textToRead = """
        Profile. \(patient.userData.Name).
        Personal Information. Patient ID \(patient.patientId). Date of Birth \(patient.userData.Dob). Email \(patient.userData.Email).
        Contact Information. Phone Number \(patient.userData.phoneNo). Address \(patient.userData.Address). Aadhar Number \(patient.userData.aadharNo.isEmpty ? "Not Provided" : patient.userData.aadharNo). Emergency Contacts \(patient.emergencyContact.map { "\($0.name) \($0.Number)" }.joined(separator: ", ")).
        Medical Information. Allergies \(patient.vitals.allergies.joined(separator: ", ")). Latest Blood Pressure \(patient.vitals.bp.last?.value ?? "Not Recorded"). Latest Heart Rate \(patient.vitals.heartRate.last?.value ?? "Not Recorded"). Latest Height \(patient.vitals.height.last?.value ?? "Not Recorded"). Latest Temperature \(patient.vitals.temperature.last?.value ?? "Not Recorded"). Latest Weight \(patient.vitals.weight.last?.value ?? "Not Recorded").
        """
        speak(text: textToRead)
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(FontSizeManager.font(for: 14))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .frame(width: 24)
            
            Text(title)
                .font(FontSizeManager.font(for: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Text(value)
                .font(FontSizeManager.font(for: 16, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct MultiItemProfileRow: View {
    let title: String
    let value: String
    let icon: String
    
    private var items: [String] {
        if value.isEmpty {
            return ["None"]
        } else {
            return value.components(separatedBy: ", ")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(FontSizeManager.font(for: 14))
                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .frame(width: 24)
                
                Text(title)
                    .font(FontSizeManager.font(for: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            if items.count == 1 {
                Text(items[0])
                    .font(FontSizeManager.font(for: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.leading, 36)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(FontSizeManager.font(for: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.95, green: 0.95, blue: 1.0))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 1.0), lineWidth: 1)
                            )
                    }
                }
                .padding(.leading, 36)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            if x + viewSize.width > width {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
            height = max(height, y + maxHeight)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            if x + viewSize.width > bounds.maxX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
        }
    }
}

struct EditProfileView: View {
    let patient: PatientF
    @State private var fullName: String
    @State private var email: String
    @State private var dob: String
    @State private var phoneNo: String
    @State private var address: String
    @State private var aadharNo: String
    @State private var emergencyContacts: [EmergencyContact]
    @State private var allergies: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let db = Firestore.firestore()
    
    init(patient: PatientF) {
        self.patient = patient
        self._fullName = State(initialValue: patient.userData.Name)
        self._email = State(initialValue: patient.userData.Email)
        self._dob = State(initialValue: patient.userData.Dob)
        self._phoneNo = State(initialValue: patient.userData.phoneNo)
        self._address = State(initialValue: patient.userData.Address)
        self._aadharNo = State(initialValue: patient.userData.aadharNo)
        self._emergencyContacts = State(initialValue: patient.emergencyContact)
        self._allergies = State(initialValue: patient.vitals.allergies)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    personalInfoSection
                    contactInfoSection
                    medicalInfoSection
                    saveButton
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(FontSizeManager.font(for: 18, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(FontSizeManager.font(for: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Full Name", text: $fullName)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(FontSizeManager.font(for: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Email", text: $email)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Date of Birth (DD/MM/YYYY)")
                    .font(FontSizeManager.font(for: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Date of Birth", text: $dob)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(FontSizeManager.font(for: 18, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(FontSizeManager.font(for: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Phone Number", text: $phoneNo)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Address")
                    .font(FontSizeManager.font(for: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Address", text: $address)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Aadhar Number (Optional)")
                    .font(FontSizeManager.font(for: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                TextField("Aadhar Number", text: $aadharNo)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            EditableEmergencyContactsSection(
                title: "Emergency Contacts",
                contacts: $emergencyContacts
            )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var medicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Medical Information")
                .font(FontSizeManager.font(for: 18, weight: .bold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            EditableItemsSection(
                title: "Allergies",
                placeholder: "Allergy",
                items: $allergies,
                addButtonLabel: "Add Allergy"
            )
            .animation(nil, value: allergies)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var saveButton: some View {
        Button(action: {
            guard let user = Auth.auth().currentUser else {
                print("No authenticated user found")
                return
            }
            
            let updatedPatient = PatientF(
                emergencyContact: emergencyContacts,
                medicalRecords: patient.medicalRecords,
                testResults: patient.testResults,
                userData: UserData(
                    Address: address,
                    Dob: dob,
                    Email: email,
                    Name: fullName,
                    Password: patient.userData.Password,
                    aadharNo: aadharNo,
                    phoneNo: phoneNo
                ),
                vitals: Vitals(
                    allergies: allergies,
                    bp: patient.vitals.bp,
                    heartRate: patient.vitals.heartRate,
                    height: patient.vitals.height,
                    temperature: patient.vitals.temperature,
                    weight: patient.vitals.weight
                ),
                lastModified: Date(),
                patientId: patient.patientId
            )
            
            do {
                try db.collection("patients").document(user.uid).setData(from: updatedPatient) { error in
                    if let error = error {
                        print("Error saving patient data: \(error.localizedDescription)")
                    } else {
                        print("Patient data updated successfully")
                        AuthManager.shared.currentPatient = updatedPatient
                        dismiss()
                    }
                }
            } catch {
                print("Error encoding patient data: \(error.localizedDescription)")
            }
        }) {
            Text("Save Changes")
                .font(FontSizeManager.font(for: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.43, green: 0.34, blue: 0.99),
                            Color(red: 0.55, green: 0.48, blue: 0.99)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct EditableEmergencyContactsSection: View {
    let title: String
    @Binding var contacts: [EmergencyContact]
    @State private var newContactName: String = ""
    @State private var newContactNumber: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(FontSizeManager.font(for: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
            
            ForEach(contacts) { contact in
                HStack {
                    VStack(alignment: .leading) {
                        TextField("Name", text: .constant(contact.name))
                            .font(FontSizeManager.font(for: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .disabled(true)
                        
                        TextField("Number", text: .constant(contact.Number))
                            .font(FontSizeManager.font(for: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .disabled(true)
                    }
                    
                    Button(action: {
                        contacts.removeAll { $0.id == contact.id }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: FontSizeManager.fontSize(for: 22)))
                    }
                    .padding(.trailing, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("New Contact Name", text: $newContactName)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                
                TextField("New Contact Number", text: $newContactNumber)
                    .font(FontSizeManager.font(for: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            Button(action: {
                if !newContactName.isEmpty && !newContactNumber.isEmpty {
                    contacts.append(EmergencyContact(Number: newContactNumber, name: newContactName))
                    newContactName = ""
                    newContactNumber = ""
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Contact")
                }
                .font(FontSizeManager.font(for: 16, weight: .medium))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
        }
    }
}

struct EditableItemsSection: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    let addButtonLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(FontSizeManager.font(for: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
            
            if items.isEmpty {
                addButton
            } else {
                ForEach(items.indices, id: \.self) { index in
                    itemRow(for: index)
                }
                
                addButton
            }
        }
    }
    
    private func itemRow(for index: Int) -> some View {
        HStack {
            TextField(placeholder, text: $items[index])
                .font(FontSizeManager.font(for: 16))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            
            Button(action: {
                items.remove(at: index)
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: FontSizeManager.fontSize(for: 22)))
            }
            .padding(.trailing, 8)
        }
    }
    
    private var addButton: some View {
        Button(action: {
            items.append("")
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: FontSizeManager.fontSize(for: 16)))
                Text(addButtonLabel)
                    .font(FontSizeManager.font(for: 16, weight: .medium))
            }
            .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
}
