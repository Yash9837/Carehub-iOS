import SwiftUI
import FirebaseFirestore

// Patient1 struct (from patients collection)
struct Patient1: Codable, Identifiable {
    let id: String // Firestore document ID
    let fullName: String
    let generatedID: String
    let age: String
    let previousProblems: String
    let allergies: String
    let medications: String
}

// MedicalTest struct (from medicalTests collection)
struct MedicalTest: Codable, Identifiable {
    let id: String // Firestore document ID
    let date: String
    let notes: String
    let patientId: String
    let results: String
    let status: String
    let testName: String
}

// Combined data structure to link MedicalTest with Patient1
struct PatientWithTest: Identifiable {
    let id: String // Use medicalTest id
    let patient: Patient1
    let medicalTest: MedicalTest
}

// PatientCard View (updated with navigation)
struct PatientCard: View {
    let patientWithTest: PatientWithTest
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack(spacing: 16) {
            // Patient Image with improved styling
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
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
            
            // Patient Details
            VStack(alignment: .leading, spacing: 6) {
                Text(patientWithTest.patient.fullName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text("Test: \(patientWithTest.medicalTest.testName)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Text("ID: \(patientWithTest.patient.generatedID) | Age: \(patientWithTest.patient.age)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    
                    Text(patientWithTest.medicalTest.status)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.7))
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            // Disclosure indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                .padding(.trailing, 8)
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
}

// HomeView_LT View
struct HomeView_LT: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var patientsWithTests: [PatientWithTest] = []
    @State private var isLoading = false
    
    let categories = ["All", "Blood Count", "Lipid Panel", "Thyroid Function", "Glucose Test", "Cholesterol Test", "Allergy Test", "Joint Fluid Analysis", "Blood Test"]
    
    var filteredPatients: [PatientWithTest] {
        patientsWithTests.filter { patientWithTest in
            (searchText.isEmpty || patientWithTest.patient.fullName.lowercased().contains(searchText.lowercased())) &&
            (selectedCategory == "All" || patientWithTest.medicalTest.testName == selectedCategory)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Search Bar with Filter Button
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    .font(.system(size: 18))
                                    .padding(.leading, 12)
                                
                                TextField("Search by patient name...", text: $searchText)
                                    .font(.system(size: 16))
                                    .padding(.vertical, 12)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                            .padding(.leading, 16)
                            
                            Menu {
                                Picker("Filter by Test", selection: $selectedCategory) {
                                    ForEach(categories, id: \.self) { category in
                                        Text(category)
                                            .foregroundColor(.black)
                                    }
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                                    .font(.system(size: 28))
                                    .frame(width: 45, height: 45)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                            }
                            .padding(.trailing, 16)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        
                        // Section title with count
                        HStack {
                            Text(selectedCategory == "All" ? "Pending Tests" : selectedCategory)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            
                            Text("(\(filteredPatients.count))")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                        
                        // Loading Indicator or Patient Cards
                        if isLoading {
                            ProgressView()
                                .padding(.vertical, 20)
                        } else if filteredPatients.isEmpty {
                            Text("No pending tests found")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.vertical, 20)
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(filteredPatients, id: \.id) { patientWithTest in
                                    NavigationLink(destination: UpdateTestView(medicalTestId: patientWithTest.medicalTest.id)) {
                                        PatientCard(patientWithTest: patientWithTest)
                                    }
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Lab Technician")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchPendingTests()
            }
        }
    }
    
    private func fetchPendingTests() {
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("medicalTests")
            .whereField("status", isEqualTo: "Pending")
            .addSnapshotListener { (snapshot, error) in
                isLoading = false
                if let error = error {
                    print("Error fetching medical tests: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                let medicalTests = documents.compactMap { doc -> MedicalTest? in
                    let data = doc.data()
                    return MedicalTest(
                        id: doc.documentID,
                        date: data["date"] as? String ?? "",
                        notes: data["notes"] as? String ?? "",
                        patientId: data["patientId"] as? String ?? "",
                        results: data["results"] as? String ?? "",
                        status: data["status"] as? String ?? "",
                        testName: data["testName"] as? String ?? ""
                    )
                }
                
                let patientIds = Set(medicalTests.map { $0.patientId })
                var patientDict: [String: Patient1] = [:]
                
                let patientGroup = DispatchGroup()
                
                for patientId in patientIds {
                    patientGroup.enter()
                    db.collection("patients").document(patientId).getDocument { (doc, error) in
                        defer { patientGroup.leave() }
                        if let doc = doc, doc.exists, let data = doc.data() {
                            let patient = Patient1(
                                id: doc.documentID,
                                fullName: data["fullName"] as? String ?? "",
                                generatedID: data["generatedID"] as? String ?? "",
                                age: data["age"] as? String ?? "",
                                previousProblems: data["previousProblems"] as? String ?? "",
                                allergies: data["allergies"] as? String ?? "",
                                medications: data["medications"] as? String ?? ""
                            )
                            patientDict[patientId] = patient
                        }
                    }
                }
                
                patientGroup.notify(queue: .main) {
                    let patientWithTests = medicalTests.compactMap { medicalTest in
                        if let patient = patientDict[medicalTest.patientId] {
                            return PatientWithTest(id: medicalTest.id, patient: patient, medicalTest: medicalTest)
                        }
                        return nil
                    }
                    self.patientsWithTests = patientWithTests
                }
            }
    }
}

// Preview Provider
struct HomeView_LT_Previews: PreviewProvider {
    static var previews: some View {
        HomeView_LT()
    }
}
