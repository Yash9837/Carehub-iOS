////
////  Records_LT.swift
////  Carehub
////
////  Created by admin24 on 21/04/25.
////
//
//import SwiftUI
//
//// Renamed from Patient to PatientInfo
//struct PatientInfo: Identifiable, Codable {
//    let id = UUID()
//    let fullName: String
//    let generatedID: String
//    let age: String
//    let previousProblems: String
//    let allergies: String
//    let medications: String
//}
//
//struct PatientRecordCard: View {
//    let patient: PatientInfo
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // Header with Patient Name and ID
//            HStack {
//                Text(patient.fullName)
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.black)
//                
//                Spacer()
//                
//                Text("ID: \(patient.generatedID)")
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(.gray)
//            }
//            
//            // Patient Details
//            VStack(alignment: .leading, spacing: 8) {
//                // Age
//                HStack {
//                    Image(systemName: "person.fill")
//                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                        .font(.system(size: 12))
//                    Text("Age: \(patient.age)")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.black.opacity(0.7))
//                }
//                
//                // Previous Problems
//                HStack {
//                    Image(systemName: "stethoscope")
//                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                        .font(.system(size: 12))
//                    Text("Previous Problems: \(patient.previousProblems)")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.black.opacity(0.7))
//                        .lineLimit(2)
//                }
//                
//                // Allergies
//                HStack {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                        .font(.system(size: 12))
//                    Text("Allergies: \(patient.allergies)")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.black.opacity(0.7))
//                        .lineLimit(2)
//                }
//                
//                // Medications/Test
//                HStack {
//                    Image(systemName: "pills.fill")
//                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                        .font(.system(size: 12))
//                    Text("Test: \(patient.medications)")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.black.opacity(0.7))
//                }
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 14)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
//        )
//        .padding(.horizontal, 16)
//        .padding(.vertical, 8)
//    }
//}
//
//struct Records_LT: View {
//    @State private var searchText = ""
//    @State private var selectedCategory = "All"
//
//    @State private var patients: [PatientInfo] = [
//        PatientInfo(fullName: "John Doe", generatedID: "PT1234", age: "45", previousProblems: "Hypertension", allergies: "Penicillin", medications: "Blood Count"),
//        PatientInfo(fullName: "Jane Smith", generatedID: "PT5678", age: "32", previousProblems: "None", allergies: "None", medications: "Lipid Panel"),
//        PatientInfo(fullName: "Mike Johnson", generatedID: "PT9012", age: "60", previousProblems: "Diabetes", allergies: "Sulfa drugs", medications: "Thyroid Function"),
//        PatientInfo(fullName: "Sarah Williams", generatedID: "PT3456", age: "28", previousProblems: "Asthma", allergies: "Peanuts", medications: "Glucose Test"),
//        PatientInfo(fullName: "Robert Brown", generatedID: "PT7890", age: "50", previousProblems: "Heart Disease", allergies: "Aspirin", medications: "Cholesterol Test"),
//        PatientInfo(fullName: "Emily Davis", generatedID: "PT4567", age: "35", previousProblems: "Allergies", allergies: "Pollen", medications: "Allergy Test"),
//        PatientInfo(fullName: "Thomas Lee", generatedID: "PT2345", age: "55", previousProblems: "Arthritis", allergies: "None", medications: "Joint Fluid Analysis"),
//        PatientInfo(fullName: "Lisa White", generatedID: "PT6789", age: "40", previousProblems: "Migraine", allergies: "Ibuprofen", medications: "Blood Test")
//    ]
//
//    let testResults: [TestResult] = [
//        TestResult(id: UUID().uuidString, testName: "Blood Count", date: "2025-04-15", status: "Completed", results: "Normal", notes: "No abnormalities detected."),
//        TestResult(id: UUID().uuidString, testName: "Lipid Panel", date: "2025-04-10", status: "Abnormal", results: "High cholesterol", notes: "Follow-up required."),
//        TestResult(id: UUID().uuidString, testName: "Thyroid Function", date: "2025-04-12", status: "Pending", results: "", notes: "Awaiting lab results.")
//    ]
//
//    let categories = ["All", "Blood Count", "Lipid Panel", "Thyroid Function", "Glucose Test", "Cholesterol Test", "Allergy Test", "Joint Fluid Analysis", "Blood Test"]
//
//    var filteredPatients: [PatientInfo] {
//        patients.filter { patient in
//            (searchText.isEmpty || patient.fullName.lowercased().contains(searchText.lowercased())) &&
//            (selectedCategory == "All" || patient.medications == selectedCategory)
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(red: 0.94, green: 0.94, blue: 1.0)
//                    .edgesIgnoringSafeArea(.all)
//                
//                ScrollView {
//                    VStack(spacing: 0) {
//                        // Search Bar with Filter Button
//                        HStack {
//                            HStack {
//                                Image(systemName: "magnifyingglass")
//                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                                    .font(.system(size: 18))
//                                    .padding(.leading, 12)
//                                
//                                TextField("Search by patient name...", text: $searchText)
//                                    .font(.system(size: 16))
//                                    .padding(.vertical, 12)
//                            }
//                            .background(Color.white)
//                            .cornerRadius(12)
//                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
//                            .padding(.leading, 16)
//                            
//                            Menu {
//                                Picker("Filter by Test", selection: $selectedCategory) {
//                                    ForEach(categories, id: \.self) { category in
//                                        Text(category)
//                                            .foregroundColor(.black)
//                                    }
//                                }
//                            } label: {
//                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
//                                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                                    .font(.system(size: 28))
//                                    .frame(width: 45, height: 45)
//                                    .background(Color.white)
//                                    .clipShape(Circle())
//                                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
//                            }
//                            .padding(.trailing, 16)
//                        }
//                        .padding(.top, 16)
//                        .padding(.bottom, 16)
//                        
//                        // Section title with count
//                        HStack {
//                            Text(selectedCategory == "All" ? "All Records" : selectedCategory)
//                                .font(.system(size: 18, weight: .bold))
//                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                            
//                            Text("(\(filteredPatients.count))")
//                                .font(.system(size: 18, weight: .medium))
//                                .foregroundColor(.gray)
//                            
//                            Spacer()
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 14)
//                        
//                        // Patient Records List
//                        LazyVStack(spacing: 0) {
//                            ForEach(filteredPatients, id: \.generatedID) { patient in
//                                NavigationLink(
//                                    destination: PatientRecordView(
//                                        patient: patient,
//                                        testResults: testResults.filter { $0.testName == patient.medications }
//                                    )
//                                ) {
//                                    PatientRecordCard(patient: patient)
//                                }
//                            }
//                        }
//                        .padding(.bottom, 24)
//                    }
//                }
//            }
//            .navigationTitle("Patient Records")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//struct PatientRecordView: View {
//    let patient: PatientInfo
//    let testResults: [TestResult]
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                // Patient Header
//                HStack(spacing: 16) {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 60, height: 60)
//                        .foregroundColor(.white)
//                        .padding(8)
//                        .background(
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    Color(red: 0.43, green: 0.34, blue: 0.99),
//                                    Color(red: 0.55, green: 0.48, blue: 0.99)
//                                ]),
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .clipShape(Circle())
//                        .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 5, x: 0, y: 3)
//                    
//                    VStack(alignment: .leading, spacing: 6) {
//                        Text(patient.fullName)
//                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundColor(.black)
//                        
//                        Text("ID: \(patient.generatedID)")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(.gray)
//                        
//                        Text("Age: \(patient.age) years")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(.gray)
//                    }
//                    
//                    Spacer()
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
//                .padding(.horizontal)
//                
//                // Medical Information Section
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Medical Information")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                        .padding(.bottom, 4)
//                    
//                    InfoRow1(title: "Previous Problems", value: patient.previousProblems)
//                    InfoRow1(title: "Allergies", value: patient.allergies)
//                    InfoRow1(title: "Current Medications", value: patient.medications)
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
//                .padding(.horizontal)
//                
//                // Test Results Section
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Test Results")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                        .padding(.bottom, 4)
//                    
//                    ForEach(testResults) { result in
//                        TestResultCard(result: result)
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
//                .padding(.horizontal)
//                
//                // Add New Result Button
//                Button(action: {
//                    // Action to add new test result
//                }) {
//                    HStack {
//                        Image(systemName: "plus.circle.fill")
//                            .font(.system(size: 20))
//                        Text("Add New Test Result")
//                            .font(.system(size: 16, weight: .semibold))
//                    }
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(
//                        LinearGradient(
//                            gradient: Gradient(colors: [
//                                Color(red: 0.43, green: 0.34, blue: 0.99),
//                                Color(red: 0.55, green: 0.48, blue: 0.99)
//                            ]),
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                    .cornerRadius(12)
//                    .shadow(color: Color(red: 0.43, green: 0.34, blue: 0.99).opacity(0.3), radius: 5, x: 0, y: 3)
//                }
//                .padding()
//            }
//            .padding(.vertical)
//        }
//        .background(Color(red: 0.94, green: 0.94, blue: 1.0))
//        .navigationTitle("Patient Records")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//struct InfoRow1: View {
//    let title: String
//    let value: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.gray)
//            
//            Text(value.isEmpty ? "Not specified" : value)
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.black)
//                .padding(.bottom, 8)
//            
//            Divider()
//        }
//    }
//}
//
//struct TestResult: Identifiable, Codable {
//    let id: String
//    let testName: String
//    let date: String
//    let status: String
//    let results: String
//    let notes: String
//}
//
//struct TestResultCard: View {
//    let result: TestResult
//    
//    var statusColor: Color {
//        switch result.status.lowercased() {
//        case "completed": return .green
//        case "pending": return .orange
//        case "abnormal": return .red
//        default: return .gray
//        }
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(result.testName)
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
//                
//                Spacer()
//                
//                Text(result.date)
//                    .font(.system(size: 14))
//                    .foregroundColor(.gray)
//            }
//            
//            HStack {
//                Text("Status:")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.gray)
//                
//                Text(result.status.capitalized)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(statusColor)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(statusColor.opacity(0.2))
//                    .cornerRadius(4)
//                
//                Spacer()
//            }
//            
//            if !result.results.isEmpty {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Results:")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.gray)
//                    
//                    Text(result.results)
//                        .font(.system(size: 15, weight: .medium))
//                }
//            }
//            
//            if !result.notes.isEmpty {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Notes:")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.gray)
//                    
//                    Text(result.notes)
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundColor(.black)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//        )
//    }
//}
//
//struct Records_LT_Previews: PreviewProvider {
//    static var previews: some View {
//        Records_LT()
//    }
//}

//
//  Records_LT.swift
//  Carehub
//
//  Created by admin24 on 21/04/25.
//

import SwiftUI

// Renamed from Patient to PatientInfo
struct PatientInfo: Identifiable, Codable {
    let id = UUID()
    let fullName: String
    let generatedID: String
    let age: String
    let previousProblems: String
    let allergies: String
    let medications: String
}

struct PatientRecordCard: View {
    let patient: PatientInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Patient Name and ID
            HStack {
                Text(patient.fullName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("ID: \(patient.generatedID)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Patient Details
            VStack(alignment: .leading, spacing: 8) {
                // Age
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    Text("Age: \(patient.age)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                }
                
                // Previous Problems
                HStack {
                    Image(systemName: "stethoscope")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    Text("Previous Problems: \(patient.previousProblems)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(2)
                }
                
                // Allergies
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12))
                    Text("Allergies: \(patient.allergies)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(2)
                }
                
                // Medications/Test
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

    @State private var patients: [PatientInfo] = [
        PatientInfo(fullName: "John Doe", generatedID: "PT1234", age: "45", previousProblems: "Hypertension", allergies: "Penicillin", medications: "Blood Count"),
        PatientInfo(fullName: "Jane Smith", generatedID: "PT5678", age: "32", previousProblems: "None", allergies: "None", medications: "Lipid Panel"),
        PatientInfo(fullName: "Mike Johnson", generatedID: "PT9012", age: "60", previousProblems: "Diabetes", allergies: "Sulfa drugs", medications: "Thyroid Function"),
        PatientInfo(fullName: "Sarah Williams", generatedID: "PT3456", age: "28", previousProblems: "Asthma", allergies: "Peanuts", medications: "Glucose Test"),
        PatientInfo(fullName: "Robert Brown", generatedID: "PT7890", age: "50", previousProblems: "Heart Disease", allergies: "Aspirin", medications: "Cholesterol Test"),
        PatientInfo(fullName: "Emily Davis", generatedID: "PT4567", age: "35", previousProblems: "Allergies", allergies: "Pollen", medications: "Allergy Test"),
        PatientInfo(fullName: "Thomas Lee", generatedID: "PT2345", age: "55", previousProblems: "Arthritis", allergies: "None", medications: "Joint Fluid Analysis"),
        PatientInfo(fullName: "Lisa White", generatedID: "PT6789", age: "40", previousProblems: "Migraine", allergies: "Ibuprofen", medications: "Blood Test")
    ]

    let testResults: [TestResult] = [
        // John Doe - Multiple Test Results
        TestResult(id: UUID().uuidString, testName: "Blood Count", date: "2025-04-15", status: "Completed", results: "Normal", notes: "No abnormalities detected."),
        TestResult(id: UUID().uuidString, testName: "Blood Count", date: "2025-03-10", status: "Completed", results: "Slightly elevated WBC", notes: "Monitor for infection."),

        // Jane Smith - Multiple Test Results
        TestResult(id: UUID().uuidString, testName: "Lipid Panel", date: "2025-04-10", status: "Abnormal", results: "High cholesterol", notes: "Follow-up required."),
        TestResult(id: UUID().uuidString, testName: "Lipid Panel", date: "2025-02-15", status: "Completed", results: "Normal", notes: "No further action needed."),

        // Mike Johnson - Single Test Result
        TestResult(id: UUID().uuidString, testName: "Thyroid Function", date: "2025-04-12", status: "Pending", results: "", notes: "Awaiting lab results."),

        // Sarah Williams - Multiple Test Results
        TestResult(id: UUID().uuidString, testName: "Glucose Test", date: "2025-04-08", status: "Completed", results: "Normal", notes: "Fasting glucose within range."),
        TestResult(id: UUID().uuidString, testName: "Glucose Test", date: "2025-01-20", status: "Abnormal", results: "Elevated glucose", notes: "Recommend dietary changes."),

        // Robert Brown - Single Test Result
        TestResult(id: UUID().uuidString, testName: "Cholesterol Test", date: "2025-04-05", status: "Completed", results: "Normal", notes: "Continue current treatment."),

        // Emily Davis - Single Test Result
        TestResult(id: UUID().uuidString, testName: "Allergy Test", date: "2025-04-03", status: "Completed", results: "Positive for pollen", notes: "Prescribe antihistamines."),

        // Thomas Lee - Multiple Test Results
        TestResult(id: UUID().uuidString, testName: "Joint Fluid Analysis", date: "2025-04-01", status: "Completed", results: "No crystals detected", notes: "Continue physical therapy."),
        TestResult(id: UUID().uuidString, testName: "Joint Fluid Analysis", date: "2025-03-05", status: "Abnormal", results: "Inflammatory markers present", notes: "Adjust medication."),

        // Lisa White - Single Test Result
        TestResult(id: UUID().uuidString, testName: "Blood Test", date: "2025-04-02", status: "Pending", results: "", notes: "Awaiting lab results.")
    ]

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
                        
                        // Patient Records List
                        LazyVStack(spacing: 0) {
                            ForEach(filteredPatients, id: \.generatedID) { patient in
                                NavigationLink(
                                    destination: PatientRecordView(
                                        patient: patient,
                                        testResults: testResults.filter { $0.testName == patient.medications }
                                    )
                                ) {
                                    PatientRecordCard(patient: patient)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Patient Records")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PatientRecordView: View {
    let patient: PatientInfo
    let testResults: [TestResult]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Patient Header
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
                
                // Medical Information Section
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
                
                // Test Results Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test Results")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .padding(.bottom, 4)
                    
                    ForEach(testResults) { result in
                        TestResultCard(result: result)
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

struct TestResult: Identifiable, Codable {
    let id: String
    let testName: String
    let date: String
    let status: String
    let results: String
    let notes: String
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
