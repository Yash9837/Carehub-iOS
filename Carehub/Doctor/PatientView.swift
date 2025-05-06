import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Patient: Identifiable {
    let id = UUID()
    let name: String
//    let gender: String
    let visitDate: String
    let patientId: String
}

struct MyPatientsView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var searchText = ""
    @State private var patients: [Patient] = []
    @State private var doctorId: String = ""
    
    private let db = Firestore.firestore()
    @State private var listener: ListenerRegistration?
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        } else {
            return patients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                PatientSearchBar(text: $searchText, placeholder: "Search patients")
                    .padding(.horizontal)
                
                // Patient List
                List(filteredPatients) { patient in
                    NavigationLink {
                        DetailsPresriptionView(patientId: patient.patientId)
                    } label: {
                        PatientInfoCard(patient: patient)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4),
                        Color.white.opacity(0.9),
                        Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("My Patients")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchDoctorIdAndPatients()
            }
            .onDisappear {
                // Clean up listener to prevent memory leaks
                listener?.remove()
                listener = nil
            }
        }
    }
    
    private func fetchDoctorIdAndPatients() {
        guard let uid = Auth.auth().currentUser?.uid else {
            doctorId = ""
            patients = []
            return
        }
        
        // Fetch doctorId from the doctors collection
        db.collection("doctors").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching doctor: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(), snapshot?.exists == true,
                  let docId = data["Doctorid"] as? String else {
                print("No doctor data found for uid: \(uid)")
                doctorId = ""
                patients = []
                return
            }
            
            doctorId = docId
            fetchPatients()
        }
    }
    
    private func fetchPatients() {
        guard !doctorId.isEmpty else {
            patients = []
            return
        }
        
        // Remove any existing listener to avoid duplicates
        listener?.remove()
        
        // Fetch appointments for the doctor and extract unique patients
        listener = db.collection("appointments")
            .whereField("docId", isEqualTo: doctorId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching appointments: \(error)")
                    patients = []
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No appointment documents found for docId: \(doctorId)")
                    patients = []
                    return
                }
                
                // Extract unique patient IDs
                let patientIds = Set(documents.compactMap { $0.data()["patientId"] as? String })
                
                // Fetch patient details
                var fetchedPatients: [Patient] = []
                let group = DispatchGroup()
                
                for patientId in patientIds {
                    group.enter()
                    db.collection("patients")
                        .whereField("patientId", isEqualTo: patientId)
                        .getDocuments { patientSnapshot, patientError in
                            defer { group.leave() }
                            
                            if let error = patientError {
                                print("Error fetching patient \(patientId): \(error)")
                                return
                            }
                            
                            // Check for valid patient document
                            guard let patientDoc = patientSnapshot?.documents.first else {
                                print("No patient document found for patientId: \(patientId)")
                                return
                            }
                            
                            // Get document data
                            let data = patientDoc.data()
                            
                            // Check and cast userData
                            guard let userData = data["userData"] as? [String: Any] else {
                                print("Invalid or missing userData for patientId: \(patientId)")
                                return
                            }
                            
                            // Extract name and gender with fallback values
                            let name = userData["Name"] as? String ?? "Unknown"
//                            let gender = userData["Gender"] as? String ?? "Unknown"
                            
                            // Get the most recent appointment date for this patient
                            let patientAppointments = documents.filter { $0.data()["patientId"] as? String == patientId }
                            let mostRecentDate = patientAppointments
                                .compactMap { ($0.data()["date"] as? Timestamp)?.dateValue() }
                                .max()
                            
                            let visitDateString = mostRecentDate?.formatted(.dateTime.day().month(.abbreviated).year().hour().minute()) ?? "N/A"
                            
                            let patient = Patient(
                                name: name,
                                visitDate: "Visited: \(visitDateString)",
                                patientId: patientId
                            )
                            fetchedPatients.append(patient)
                        }
                }
                
                group.notify(queue: .main) {
                    // Sort patients by name for consistent display
                    patients = fetchedPatients.sorted { $0.name < $1.name }
                    print("Total patients fetched: \(patients.count)")
                }
            }
    }
}

struct PatientSearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct PatientInfoCard: View {
    let patient: Patient
    
    var body: some View {
        HStack {
            // Patient Image Placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                )
                .padding(.leading, 10)
            
            // Patient Info
            VStack(alignment: .leading, spacing: 5) {
                Text(patient.name)
                    .font(.headline)
                    .foregroundColor(.white)
//                Text(patient.gender)
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))
                Text(patient.visitDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.vertical, 10)
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
                .padding(.trailing, 10)
        }
        .background(Color(red: 0.45, green: 0.44, blue: 0.99))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct MyPatientsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPatientsView()
    }
}
