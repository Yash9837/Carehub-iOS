import SwiftUI
import Firebase
import FirebaseFirestore

struct PatientProfileView: View {
    let patientIdentifier: String
    let doctorId: String
    let doctorName: String
    @State private var patientInfo: PatientProfile?
    @State private var appointment: Appointment?
    @State private var isFetching = true
    @State private var errorText: String?
    @State private var labTestsInput: String = ""
    @State private var showNotesView = false
    @State private var showPrescriptionView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToDashboard = false

    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.96, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                if isFetching {
                    ProgressView("Fetching patient profile...")
                        .tint(Color(red: 0.45, green: 0.36, blue: 0.98))
                } else if let error = errorText {
                    VStack(spacing: 16) {
                        Text("Error loading profile")
                            .font(.system(size: 18, weight: .medium))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            retrievePatientProfile()
                        }) {
                            Text("Retry")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 24)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.45, green: 0.36, blue: 0.98),
                                            Color(red: 0.57, green: 0.50, blue: 0.98)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: Color(red: 0.45, green: 0.36, blue: 0.98).opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding()
                } else if let patient = patientInfo {
                    ScrollView {
                        VStack(spacing: 16) {
                            profileCard(patient: patient)
                            vitalStatsSection(patient: patient)
                            actionButtons()
                            labRequestSection()
                            Spacer(minLength: 20)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("Patient Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("Custom back button tapped, navigating back to DoctorDashboardView")
                        navigateToDashboard = true
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(red: 0.45, green: 0.36, blue: 0.98))
                        Text("Back")
                            .foregroundColor(Color(red: 0.45, green: 0.36, blue: 0.98))
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToDashboard) {
                DoctorDashboardView()
            }
            .navigationDestination(isPresented: $showNotesView) {
                if let appointment = appointment, !doctorId.isEmpty {
                    NotesView(appointment: appointment)
                } else {
                    Text("No appointment found for this patient.")
                        .foregroundColor(.red)
                }
            }
            .navigationDestination(isPresented: $showPrescriptionView) {
                if let appointment = appointment, !doctorId.isEmpty {
                    PrescriptionView(appointment: appointment)
                } else {
                    Text("No appointment found for this patient.")
                        .foregroundColor(.red)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Lab Test Request"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("Successfully") {
                            labTestsInput = ""
                        }
                    }
                )
            }
            .onAppear {
                initializeFirebase()
                retrievePatientProfile()
            }
        }
    }
    
    private func profileCard(patient: PatientProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileDetailRow(title: "Patient ID", value: patient.patientIdentifier, icon: "person.text.rectangle")
            Divider()
                .background(Color.gray.opacity(0.2))
            
            ProfileDetailRow(title: "Name", value: patient.profileData.fullName, icon: "person.fill")
            ProfileDetailRow(title: "Contact", value: patient.profileData.contactNumber, icon: "phone.fill")
            ProfileDetailRow(title: "Email", value: patient.profileData.emailAddress, icon: "envelope.fill")
            
            if !patient.healthData.allergyList.isEmpty {
                MultiProfileRow(
                    title: "Allergies",
                    value: patient.healthData.allergyList.joined(separator: ", "),
                    icon: "allergens"
                )
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.vertical, 8)
    }
    
    private func vitalStatsSection(patient: PatientProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vitals")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.45, green: 0.36, blue: 0.98))
                .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                VitalStatCard(
                    title: "BP",
                    value: patient.healthData.bloodPressure.last?.reading ?? "N/A",
                    icon: "heart.fill",
                    color: Color(red: 0.45, green: 0.36, blue: 0.98)
                )
                
                VitalStatCard(
                    title: "Heart Rate",
                    value: patient.healthData.heartRate.last?.reading ?? "N/A",
                    icon: "waveform.path.ecg",
                    color: Color(red: 0.57, green: 0.50, blue: 0.98)
                )
            }
            
            HStack(spacing: 16) {
                VitalStatCard(
                    title: "Temperature",
                    value: patient.healthData.temperature.last?.reading ?? "N/A",
                    icon: "thermometer",
                    color: Color(red: 0.45, green: 0.36, blue: 0.98)
                )
                
                VitalStatCard(
                    title: "Weight",
                    value: patient.healthData.weight.last?.reading ?? "N/A",
                    icon: "scalemass",
                    color: Color(red: 0.57, green: 0.50, blue: 0.98)
                )
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.vertical, 8)
    }
    
    private func actionButtons() -> some View {
        HStack(spacing: 16) {
            Button(action: {
                print("Add Notes button tapped, showNotesView: \(showNotesView)")
                if appointment == nil || doctorId.isEmpty {
                    print("Cannot navigate to NotesView: appointment is nil or doctorId is empty")
                    errorText = "No appointment found or invalid doctor ID."
                    return
                }
                showNotesView = true
            }) {
                Text("Add Notes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.45, green: 0.36, blue: 0.98))
                    .cornerRadius(10)
            }
            
            Button(action: {
                print("Add Prescription button tapped, showPrescriptionView: \(showPrescriptionView)")
                if appointment == nil || doctorId.isEmpty {
                    print("Cannot navigate to PrescriptionView: appointment is nil or doctorId is empty")
                    errorText = "No appointment found or invalid doctor ID."
                    return
                }
                showPrescriptionView = true
            }) {
                Text("Add Prescription")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.57, green: 0.50, blue: 0.98))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func labRequestSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Request Lab Tests")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.45, green: 0.36, blue: 0.98))
                .padding(.horizontal, 16)
            
            TextEditor(text: $labTestsInput)
                .font(.system(size: 16))
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.45, green: 0.36, blue: 0.98), lineWidth: 1)
                )
                .padding(.horizontal, 16)
            
            Button(action: {
                requestLabTest()
            }) {
                Text("Request Lab")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.45, green: 0.36, blue: 0.98))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.vertical, 8)
    }
    
    private func initializeFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    private func retrievePatientProfile() {
        isFetching = true
        errorText = nil
        
        let db = Firestore.firestore()
        db.collection("patients").document(patientIdentifier).getDocument { document, error in
            if let error = error {
                print("Error fetching patient by document ID: \(error.localizedDescription)")
                db.collection("patients").whereField("patientId", isEqualTo: patientIdentifier).getDocuments { querySnapshot, queryError in
                    if let queryError = queryError {
                        self.errorText = "Failed to fetch data: \(queryError.localizedDescription)"
                        self.isFetching = false
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        self.errorText = "Patient not found"
                        self.isFetching = false
                        print("No patient found for patientId: \(patientIdentifier)")
                        return
                    }
                    
                    let document = documents.first!
                    do {
                        let patientData = try self.parsePatientProfile(document: document)
                        self.patientInfo = patientData
                        self.fetchAppointment()
                    } catch {
                        self.errorText = "Error parsing data: \(error.localizedDescription)"
                        self.isFetching = false
                    }
                }
                return
            }
            
            guard let document = document, document.exists else {
                db.collection("patients").whereField("patientId", isEqualTo: patientIdentifier).getDocuments { querySnapshot, queryError in
                    if let queryError = queryError {
                        self.errorText = "Failed to fetch data: \(queryError.localizedDescription)"
                        self.isFetching = false
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        self.errorText = "Patient not found"
                        self.isFetching = false
                        print("No patient found for patientId: \(patientIdentifier)")
                        return
                    }
                    
                    let document = documents.first!
                    do {
                        let patientData = try self.parsePatientProfile(document: document)
                        self.patientInfo = patientData
                        self.fetchAppointment()
                    } catch {
                        self.errorText = "Error parsing data: \(error.localizedDescription)"
                        self.isFetching = false
                    }
                }
                return
            }
            
            do {
                let patientData = try self.parsePatientProfile(document: document)
                self.patientInfo = patientData
                self.fetchAppointment()
            } catch {
                self.errorText = "Error parsing data: \(error.localizedDescription)"
                self.isFetching = false
            }
        }
    }
    
    private func fetchAppointment() {
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patientIdentifier)
            .whereField("docId", isEqualTo: doctorId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching appointment: \(error.localizedDescription)")
                    self.errorText = "Failed to fetch appointment: \(error.localizedDescription)"
                    self.isFetching = false
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No appointment found for patientId: \(patientIdentifier) and docId: \(doctorId)")
                    self.errorText = "No appointment found for this patient and doctor."
                    self.isFetching = false
                    return
                }
                
                let document = documents.first!
                do {
                    let appointmentData = try self.parseAppointment(document: document)
                    self.appointment = appointmentData
                    self.isFetching = false
                } catch {
                    self.errorText = "Error parsing appointment data: \(error.localizedDescription)"
                    self.isFetching = false
                }
            }
    }
    
    private func parsePatientProfile(document: DocumentSnapshot) throws -> PatientProfile {
        guard let data = document.data() else {
            throw NSError(domain: "DataParsingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document data was empty"])
        }
        
        guard let profileDataMap = data["userData"] as? [String: Any] else {
            throw NSError(domain: "DataParsingError", code: 2, userInfo: [NSLocalizedDescriptionKey: "UserData not found"])
        }
        
        let profileData = ProfileData(
            fullName: profileDataMap["Name"] as? String ?? "Unknown",
            dateOfBirth: profileDataMap["Dob"] as? String ?? "",
            emailAddress: profileDataMap["Email"] as? String ?? "No email",
            contactNumber: profileDataMap["phoneNo"] as? String ?? "No phone"
        )
        
        var healthData = HealthData(allergyList: [], bloodPressure: [], heartRate: [], temperature: [], weight: [])
        if let healthDataMap = data["vitals"] as? [String: Any] {
            if let allergiesArray = healthDataMap["allergies"] as? [String] {
                healthData.allergyList = allergiesArray
            }
            if let bpArray = healthDataMap["bp"] as? [[String: Any]] {
                healthData.bloodPressure = bpArray.compactMap { bpData in
                    guard let reading = bpData["value"] as? String,
                          let timestamp = bpData["timestamp"] as? Timestamp else { return nil }
                    return HealthEntry(timestamp: timestamp.dateValue(), reading: reading)
                }
            }
            if let hrArray = healthDataMap["heartRate"] as? [[String: Any]] {
                healthData.heartRate = hrArray.compactMap { hrData in
                    guard let reading = hrData["value"] as? String,
                          let timestamp = hrData["timestamp"] as? Timestamp else { return nil }
                    return HealthEntry(timestamp: timestamp.dateValue(), reading: reading)
                }
            }
            if let tempArray = healthDataMap["temperature"] as? [[String: Any]] {
                healthData.temperature = tempArray.compactMap { tempData in
                    guard let reading = tempData["value"] as? String,
                          let timestamp = tempData["timestamp"] as? Timestamp else { return nil }
                    return HealthEntry(timestamp: timestamp.dateValue(), reading: reading)
                }
            }
            if let weightArray = healthDataMap["weight"] as? [[String: Any]] {
                healthData.weight = weightArray.compactMap { weightData in
                    guard let reading = weightData["value"] as? String,
                          let timestamp = weightData["timestamp"] as? Timestamp else { return nil }
                    return HealthEntry(timestamp: timestamp.dateValue(), reading: reading)
                }
            }
        }
        
        let patientIdentifier = data["patientId"] as? String ?? document.documentID
        
        return PatientProfile(
            patientIdentifier: patientIdentifier,
            profileData: profileData,
            healthData: healthData
        )
    }
    
    private func parseAppointment(document: DocumentSnapshot) throws -> Appointment {
        guard let data = document.data() else {
            throw NSError(domain: "DataParsingError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Appointment document data was empty"])
        }
        
        let id = document.documentID
        let apptId = data["apptId"] as? String ?? ""
        let patientId = data["patientId"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let docId = data["docId"] as? String ?? ""
        let status = data["status"] as? String ?? ""
        let billingStatus = data["billingStatus"] as? String ?? ""
        let amount = data["amount"] as? Double
        let date = (data["date"] as? Timestamp)?.dateValue()
        let doctorsNotes = data["doctorsNotes"] as? String
        let prescriptionId = data["prescriptionId"] as? String
        let followUpRequired = data["followUpRequired"] as? Bool
        let followUpDate = (data["followUpDate"] as? Timestamp)?.dateValue()
        
        return Appointment(
            id: id,
            apptId: apptId,
            patientId: patientId,
            description: description,
            docId: docId,
            status: status,
            billingStatus: billingStatus,
            amount: amount,
            date: date,
            doctorsNotes: doctorsNotes,
            prescriptionId: prescriptionId,
            followUpRequired: followUpRequired,
            followUpDate: followUpDate
        )
    }
    
    private func requestLabTest() {
        guard !labTestsInput.isEmpty else {
            alertMessage = "Please enter the tests required."
            showAlert = true
            return
        }
        
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: currentDate)
        
        let labTestId = UUID().uuidString
        
        let testData: [String: Any] = [
            "date": dateString,
            "doc": doctorName,
            "id": labTestId,
            "patientId": patientIdentifier,
            "pdfUrl": "",
            "status": "Pending",
            "testName": labTestsInput
        ]
        
        db.collection("medicalTests").addDocument(data: testData) { error in
            if let error = error {
                alertMessage = "Error requesting lab test: \(error.localizedDescription)"
                showAlert = true
                print("Error adding lab test request: \(error.localizedDescription)")
            } else {
                alertMessage = "Successfully Requested"
                showAlert = true
                print("Lab test requested successfully: \(labTestsInput)")
            }
        }
    }
}

struct ProfileDetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.45, green: 0.36, blue: 0.98))
                .font(.system(size: 14))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct MultiProfileRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.45, green: 0.36, blue: 0.98))
                .font(.system(size: 14))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}

struct VitalStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .padding(.top, 2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct ProfileData {
    let fullName: String
    let dateOfBirth: String
    let emailAddress: String
    let contactNumber: String
}

struct HealthData {
    var allergyList: [String]
    var bloodPressure: [HealthEntry]
    var heartRate: [HealthEntry]
    var temperature: [HealthEntry]
    var weight: [HealthEntry]
}

struct HealthEntry {
    let timestamp: Date
    let reading: String
}

struct PatientProfile {
    let patientIdentifier: String
    let profileData: ProfileData
    let healthData: HealthData
}
