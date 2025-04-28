import SwiftUI
import FirebaseFirestore

// MARK: - UI Components

struct PatientRecordCard: View {
    let patient: PatientInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(patient.fullName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("ID: \(patient.generatedID)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    Text("Age: \(patient.age)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                }
                
                HStack {
                    Image(systemName: "stethoscope")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    Text("Previous Problems: \(patient.previousProblems)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    Text("Allergies: \(patient.allergies)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: "pills.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    Text("Test: \(patient.medications)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct Records_LT: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var patients: [PatientInfo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let categories = ["All", "Blood Count", "Lipid Panel", "Thyroid Function", "Glucose Test", "Cholesterol Test", "Allergy Test", "Joint Fluid Analysis", "Blood Test"]

    var filteredPatients: [PatientInfo] {
        patients.filter { patient in
            (searchText.isEmpty || patient.fullName.lowercased().contains(searchText.lowercased())) &&
            (selectedCategory == "All" || patient.medications == selectedCategory)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Loading records...")
                        .scaleEffect(1.5)
                } else if let error = errorMessage {
                    VStack {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            loadData()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            HStack {
                                Text(selectedCategory == "All" ? "All Records" : selectedCategory)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                
                                Text("(\(filteredPatients.count))")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 14)
                            
                            LazyVStack(spacing: 0) {
                                ForEach(filteredPatients) { patient in
                                    NavigationLink(
                                        destination: PatientRecordView(patient: patient)
                                    ) {
                                        PatientRecordCard(patient: patient)
                                    }
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Patient Records")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        isLoading = true
        errorMessage = nil
        
        FirebaseManager.shared.fetchPatients { [self] patients, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            self.patients = patients ?? []
            print("Fetched patients: \(self.patients.map { $0.generatedID })")
        }
    }
}


struct PatientRecordView: View {
    let patient: PatientInfo
    @State private var testResults: [TestResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .padding(8)
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
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(patient.fullName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("ID: \(patient.generatedID)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("Age: \(patient.age) years")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Medical Information")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .padding(.bottom, 4)
                    
                    InfoRow1(title: "Previous Problems", value: patient.previousProblems)
                    InfoRow1(title: "Allergies", value: patient.allergies)
                    InfoRow1(title: "Current Medications", value: patient.medications)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test Results")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .padding(.bottom, 4)
                    
                    if isLoading {
                        ProgressView("Loading test results...")
                            .padding()
                    } else if let error = errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    } else if testResults.isEmpty {
                        Text("No test results found.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(testResults) { result in
                            TestResultCard(result: result)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(red: 0.94, green: 0.94, blue: 1.0))
        .navigationTitle("Patient Records")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTestResults()
        }
    }
    
    private func loadTestResults() {
        isLoading = true
        errorMessage = nil
        
        FirebaseManager.shared.fetchTestResults(forPatientId: patient.generatedID) { results, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            self.testResults = results ?? []
            print("Fetched test results for patient \(patient.generatedID): \(self.testResults.count)")
        }
    }
}

struct InfoRow1: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            Text(value.isEmpty ? "Not specified" : value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.bottom, 8)
            
            Divider()
        }
    }
}


struct TestResultCard: View {
    let result: TestResult
    
    var statusColor: Color {
        switch result.status.lowercased() {
        case "completed": return .green
        case "pending": return .orange
        case "abnormal": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.testName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                
                Spacer()
                
                Text(result.date)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Status:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(result.status.capitalized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
            }
            
            if !result.results.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Results:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(result.results)
                        .font(.system(size: 15, weight: .medium))
                }
            }
            
            if !result.notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(result.notes)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            
            Button(action: {
                if let pdfUrl = URL(string: result.pdfUrl) {
                    UIApplication.shared.open(pdfUrl, options: [:], completionHandler: nil)
                }
            }) {
                Text("View PDF")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.43, green: 0.34, blue: 0.99))
                    .cornerRadius(8)
            }
            .padding(.top, 8)
            .disabled(result.pdfUrl.isEmpty)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
struct Records_LT_Previews: PreviewProvider {
    static var previews: some View {
        Records_LT()
    }
}
