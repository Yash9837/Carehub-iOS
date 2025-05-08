import SwiftUI
import Firebase
import FirebaseFirestore

struct DetailsPresriptionView: View {
    let patientId: String // This should be passed dynamically from the previous view
    @State private var patient: PatientF?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var doctorNotes: [DoctorsNote] = []
    @State private var medicalTestPDFs: [MedicalTestPDF] = []
    
    private var age: Int? {
        guard let dobString = patient?.userData.Dob else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let dob = dateFormatter.date(from: dobString) else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return ageComponents.year
    }
    
    private let purpleColor = Color(red: 0.43, green: 0.34, blue: 0.99)
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView("Loading patient data...")
                    .tint(purpleColor)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Text("Error loading data")
                        .font(.system(size: 18, weight: .medium))
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        fetchPatientData()
                        fetchDoctorNotes()
                        fetchMedicalTestPDFs()
                    }) {
                        Text("Retry")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 24)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        purpleColor,
                                        Color(red: 0.55, green: 0.48, blue: 0.99)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: purpleColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
                .padding()
            } else if let patient = patient {
                ScrollView {
                    VStack(spacing: 16) {
                        patientInfoCard(patient: patient)
                        vitalsSection(patient: patient)
                        medicalRecordsSection(records: patient.medicalRecords)
                        testResultsSection(results: patient.testResults)
                        doctorsNotesSection()
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle("Patient Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("DetailsPresriptionView appeared with patientId: \(patientId)") // Debug log
            setupFirebase()
            fetchPatientData()
            fetchDoctorNotes()
            fetchMedicalTestPDFs()
        }
    }
    
    private func patientInfoCard(patient: PatientF) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(purpleColor)
                    .font(.system(size: 14))
                    .frame(width: 24)
                
                Text("Patient ID")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(patient.patientId)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            DetailRow(title: "Name", value: patient.userData.Name, icon: "person.fill")
            DetailRow(title: "Age", value: age != nil ? "\(age!) years" : "Unknown", icon: "calendar")
            DetailRow(title: "Contact", value: patient.userData.phoneNo, icon: "phone.fill")
            DetailRow(title: "Email", value: patient.userData.Email, icon: "envelope.fill")
            DetailRow(title: "Address", value: patient.userData.Address, icon: "house.fill")
            
            if !patient.vitals.allergies.isEmpty {
                MultiItemProfileRow(
                    title: "Allergies",
                    value: patient.vitals.allergies.joined(separator: ", "),
                    icon: "allergens"
                )
            }
            
            if !patient.emergencyContact.isEmpty {
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                Text("Emergency Contacts")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(purpleColor)
                    .padding(.top, 4)
                
                ForEach(patient.emergencyContact) { contact in
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .foregroundColor(purpleColor)
                            .font(.system(size: 14))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contact.name)
                                .font(.system(size: 16))
                            Text(contact.Number)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 6)
                }
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

    private func vitalsSection(patient: PatientF) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vitals")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(purpleColor)
                .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                VitalCard(
                    title: "BP",
                    value: patient.vitals.bp.last?.value ?? "N/A",
                    icon: "heart.fill",
                    color: purpleColor
                )
                
                VitalCard(
                    title: "Heart Rate",
                    value: patient.vitals.heartRate.last?.value ?? "N/A",
                    icon: "waveform.path.ecg",
                    color: Color(red: 0.55, green: 0.48, blue: 0.99)
                )
            }
            
            HStack(spacing: 16) {
                VitalCard(
                    title: "Temperature",
                    value: patient.vitals.temperature.last?.value ?? "N/A",
                    icon: "thermometer",
                    color: purpleColor
                )
                
                VitalCard(
                    title: "Weight",
                    value: patient.vitals.weight.last?.value ?? "N/A",
                    icon: "scalemass",
                    color: Color(red: 0.55, green: 0.48, blue: 0.99)
                )
            }
            
            HStack(spacing: 16) {
                VitalCard(
                    title: "Height",
                    value: patient.vitals.height.last?.value ?? "N/A",
                    icon: "ruler",
                    color: purpleColor
                )
                
                Spacer()
                    .frame(maxWidth: .infinity)
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

    private func medicalRecordsSection(records: [MedicalRecord]) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Medical Records")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(purpleColor)
                    .padding(.horizontal, 16)
                
                if records.isEmpty && medicalTestPDFs.isEmpty {
                    Text("No medical records available")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)
                } else {
                    ForEach(records) { record in
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(purpleColor)
                                .font(.system(size: 16))
                                .frame(width: 24)
                            
                            Text(record.name)
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            Button(action: {
                                if let url = URL(string: record.url) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image(systemName: "arrow.down.doc")
                                    .foregroundColor(purpleColor)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    
                    ForEach(medicalTestPDFs) { testPDF in
                        NavigationLink(destination: PDFViewer(pdfUrl: testPDF.url)) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(purpleColor)
                                    .font(.system(size: 16))
                                    .frame(width: 24)
                                
                                Text(testPDF.testName)
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                Image(systemName: "arrow.down.doc")
                                    .foregroundColor(purpleColor)
                                    .font(.system(size: 18))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                    }
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
        
    private func fetchMedicalTestPDFs() {
        let db = Firestore.firestore()
        print("Querying medicalTests for patientId: \(patientId)") // Debug log
        
        db.collection("medicalTests")
            .whereField("patientId", isEqualTo: patientId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching medical tests: \(error.localizedDescription)")
                    self.medicalTestPDFs = []
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found in snapshot for patientId: \(self.patientId)")
                    self.medicalTestPDFs = []
                    return
                }
                
                print("Found \(documents.count) documents")
                self.medicalTestPDFs = documents.compactMap { doc -> MedicalTestPDF? in
                    let data = doc.data()
                    print("Document data: \(data)") // Debug log
                    
                    // Use the field name from your screenshot (pdfUrl instead of pdfURL)
                    guard let pdfURLString = data["pdfUrl"] as? String,
                          let testName = data["testName"] as? String,
                          let url = URL(string: pdfURLString) else {
                        print("Failed to parse document: \(doc.documentID)")
                        return nil
                    }
                    
                    return MedicalTestPDF(testName: testName, url: url)
                }
                print("Fetched medical test PDFs: \(self.medicalTestPDFs.count)")
            }
    }
    
    private func testResultsSection(results: [TestResultF]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prescriptions")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(purpleColor)
                .padding(.horizontal, 16)
            
            if results.isEmpty {
                Text("No Prescriptions available")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                ForEach(results) { result in
                    HStack {
                        Image(systemName: "testtube.2")
                            .foregroundColor(purpleColor)
                            .font(.system(size: 16))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text(result.testType)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(formatDate(result.dateCreated))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let url = URL(string: result.url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "arrow.down.doc")
                                .foregroundColor(purpleColor)
                                .font(.system(size: 18))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
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

    private func doctorsNotesSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Doctor's Notes")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(purpleColor)
                .padding(.horizontal, 16)
            
            if doctorNotes.isEmpty {
                Text("No notes available")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                ForEach(doctorNotes) { note in
                    NoteCard(note: note, color: purpleColor)
                }
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

    private func setupFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    private func fetchPatientData() {
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        db.collection("patients").document(patientId).getDocument { document, error in
            if let error = error {
                print("Error fetching patient by document ID: \(error.localizedDescription)")
                db.collection("patients").whereField("patientId", isEqualTo: patientId).getDocuments { querySnapshot, queryError in
                    if let queryError = queryError {
                        self.errorMessage = "Failed to fetch data: \(queryError.localizedDescription)"
                        self.isLoading = false
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        self.errorMessage = "Patient not found"
                        self.isLoading = false
                        print("No patient found for patientId: \(patientId)")
                        return
                    }
                    
                    let document = documents.first!
                    do {
                        let patientData = try self.parsePatientData(document: document)
                        self.patient = patientData
                        self.isLoading = false
                    } catch {
                        self.errorMessage = "Error parsing data: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
                return
            }
            
            guard let document = document, document.exists else {
                db.collection("patients").whereField("patientId", isEqualTo: patientId).getDocuments { querySnapshot, queryError in
                    if let queryError = queryError {
                        self.errorMessage = "Failed to fetch data: \(queryError.localizedDescription)"
                        self.isLoading = false
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        self.errorMessage = "Patient not found"
                        self.isLoading = false
                        print("No patient found for patientId: \(patientId)")
                        return
                    }
                    
                    let document = documents.first!
                    do {
                        let patientData = try self.parsePatientData(document: document)
                        self.patient = patientData
                        self.isLoading = false
                    } catch {
                        self.errorMessage = "Error parsing data: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
                return
            }
            
            do {
                let patientData = try self.parsePatientData(document: document)
                self.patient = patientData
                self.isLoading = false
            } catch {
                self.errorMessage = "Error parsing data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func fetchDoctorNotes() {
        let db = Firestore.firestore()
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patientId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching doctor notes: \(error.localizedDescription)")
                    self.doctorNotes = []
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No appointment documents found for patientId: \(self.patientId)")
                    self.doctorNotes = []
                    return
                }
                
                self.doctorNotes = documents.compactMap { doc -> DoctorsNote? in
                    let data = doc.data()
                    guard let apptId = data["apptId"] as? String,
                          let patientId = data["patientId"] as? String,
                          let note = (data["doctorsNotes"] as? String) ?? (data["doctorNotes"] as? String) else {
                        return nil
                    }
                    return DoctorsNote(
                        appointmentID: apptId,
                        note: note,
                        patientID: patientId
                    )
                }
                print("Fetched doctor notes: \(self.doctorNotes.count)")
            }
    }
    
    private func parsePatientData(document: DocumentSnapshot) throws -> PatientF {
        guard let data = document.data() else {
            throw NSError(domain: "DataParsingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document data was empty"])
        }
        
        guard let userDataMap = data["userData"] as? [String: Any] else {
            throw NSError(domain: "DataParsingError", code: 2, userInfo: [NSLocalizedDescriptionKey: "UserData not found"])
        }
        
        let userData = UserData(
            Address: userDataMap["Address"] as? String ?? "Unknown",
            Dob: userDataMap["Dob"] as? String ?? "",
            Email: userDataMap["Email"] as? String ?? "No email",
            Name: userDataMap["Name"] as? String ?? "Unknown",
            Password: userDataMap["Password"] as? String ?? "",
            aadharNo: userDataMap["aadharNo"] as? String ?? "",
            phoneNo: userDataMap["phoneNo"] as? String ?? "No phone"
        )
        
        let username = data["username"] as? String ?? userDataMap["username"] as? String ?? ""
        
        var vitals = Vitals(allergies: [], bp: [], heartRate: [], height: [], temperature: [], weight: [])
        if let vitalsMap = data["vitals"] as? [String: Any] {
            if let allergiesArray = vitalsMap["allergies"] as? [String] {
                vitals.allergies = allergiesArray
            }
            if let bpArray = vitalsMap["bp"] as? [[String: Any]] {
                vitals.bp = bpArray.compactMap { bpData in
                    guard let value = bpData["value"] as? String,
                          let timestamp = bpData["timestamp"] as? Timestamp else { return nil }
                    return VitalEntry(timestamp: timestamp.dateValue(), value: value)
                }
            }
            if let hrArray = vitalsMap["heartRate"] as? [[String: Any]] {
                vitals.heartRate = hrArray.compactMap { hrData in
                    guard let value = hrData["value"] as? String,
                          let timestamp = hrData["timestamp"] as? Timestamp else { return nil }
                    return VitalEntry(timestamp: timestamp.dateValue(), value: value)
                }
            }
            if let tempArray = vitalsMap["temperature"] as? [[String: Any]] {
                vitals.temperature = tempArray.compactMap { tempData in
                    guard let value = tempData["value"] as? String,
                          let timestamp = tempData["timestamp"] as? Timestamp else { return nil }
                    return VitalEntry(timestamp: timestamp.dateValue(), value: value)
                }
            }
            if let weightArray = vitalsMap["weight"] as? [[String: Any]] {
                vitals.weight = weightArray.compactMap { weightData in
                    guard let value = weightData["value"] as? String,
                          let timestamp = weightData["timestamp"] as? Timestamp else { return nil }
                    return VitalEntry(timestamp: timestamp.dateValue(), value: value)
                }
            }
            if let heightArray = vitalsMap["height"] as? [[String: Any]] {
                vitals.height = heightArray.compactMap { heightData in
                    guard let value = heightData["value"] as? String,
                          let timestamp = heightData["timestamp"] as? Timestamp else { return nil }
                    return VitalEntry(timestamp: timestamp.dateValue(), value: value)
                }
            }
        }
        
        var medicalRecords: [MedicalRecord] = []
        if let recordsArray = data["medicalRecords"] as? [[String: Any]] {
            medicalRecords = recordsArray.compactMap { recordData in
                guard let name = recordData["name"] as? String,
                      let url = recordData["url"] as? String else { return nil }
                return MedicalRecord(name: name, url: url)
            }
        }
        
        var testResults: [TestResultF] = []
        if let resultsArray = data["testResults"] as? [[String: Any]] {
            testResults = resultsArray.compactMap { resultData in
                guard let testType = resultData["testType"] as? String,
                      let url = resultData["url"] as? String,
                      let dateCreated = resultData["dateCreated"] as? Timestamp,
                      let labTechId = resultData["labTechId"] as? String else { return nil }
                return TestResultF(dateCreated: dateCreated.dateValue(), labTechId: labTechId, testType: testType, url: url)
            }
        }
        
        var emergencyContacts: [EmergencyContact] = []
        if let contactsArray = data["emergencyContact"] as? [[String: Any]] {
            emergencyContacts = contactsArray.compactMap { contactData in
                guard let name = contactData["name"] as? String,
                      let number = contactData["Number"] as? String else { return nil }
                return EmergencyContact(Number: number, name: name)
            }
        }
        
        let lastModified = (data["lastModified"] as? Timestamp)?.dateValue() ?? Date()
        let patientId = data["patientId"] as? String ?? document.documentID
        
        return PatientF(
            emergencyContact: emergencyContacts,
            medicalRecords: medicalRecords,
            testResults: testResults,
            userData: userData,
            vitals: vitals,
            lastModified: lastModified,
            patientId: patientId
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
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

struct VitalCard: View {
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

struct MedicalTestPDF: Identifiable {
    let id = UUID()
    let testName: String
    let url: URL
}

struct MultiItemProfileRows: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .font(.system(size: 14))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
    }
}

struct DetailsPresriptionView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsPresriptionView(patientId: "PT001")
    }
}

struct NoteCard: View {
    let note: DoctorsNote
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(color)
                    .font(.system(size: 16))
                Text("Appointment ID: \(note.appointmentID)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
            }
            Text("Patient ID: \(note.patientID)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.7))
            Text(note.note)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.65))
                .lineLimit(2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(color: color.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}

struct DoctorsNote: Identifiable {
    let id = UUID()
    let appointmentID: String
    let note: String
    let patientID: String
}
