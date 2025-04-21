import SwiftUI

//struct Patient: Codable {
//    let fullName: String
//    let generatedID: String
//    let age: String
//    let previousProblems: String
//    let allergies: String
//    let medications: String
//}

struct PatientCard: View {
    let patient: Patient
    
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
            
            // Patient Details with reduced font sizes and added ID & Age
            VStack(alignment: .leading, spacing: 6) {
                Text(patient.fullName)
                    .font(.system(size: 18, weight: .semibold)) // Reduced from 20
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text("Test: \(patient.medications)")
                    .font(.system(size: 14, weight: .medium)) // Reduced from 16
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Text("ID: \(patient.generatedID) | Age: \(patient.age)")
                        .font(.system(size: 12, weight: .medium)) // Reduced from 14
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                        .font(.system(size: 12)) // Reduced from 14
                    
                    Text("Pending")
                        .font(.system(size: 12, weight: .medium)) // Reduced from 14
                        .foregroundColor(Color.black.opacity(0.7))
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            // Disclosure indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold)) // Reduced from 14
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

struct HomeView_LT: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var patients: [Patient] = [
        Patient(fullName: "John Doe", generatedID: "PT1234", age: "45", previousProblems: "Hypertension", allergies: "Penicillin", medications: "Blood Count"),
        Patient(fullName: "Jane Smith", generatedID: "PT5678", age: "32", previousProblems: "None", allergies: "None", medications: "Lipid Panel"),
        Patient(fullName: "Mike Johnson", generatedID: "PT9012", age: "60", previousProblems: "Diabetes", allergies: "Sulfa drugs", medications: "Thyroid Function"),
        Patient(fullName: "Sarah Williams", generatedID: "PT3456", age: "28", previousProblems: "Asthma", allergies: "Peanuts", medications: "Glucose Test"),
        Patient(fullName: "Robert Brown", generatedID: "PT7890", age: "50", previousProblems: "Heart Disease", allergies: "Aspirin", medications: "Cholesterol Test"),
        Patient(fullName: "Emily Davis", generatedID: "PT4567", age: "35", previousProblems: "Allergies", allergies: "Pollen", medications: "Allergy Test"),
        Patient(fullName: "Thomas Lee", generatedID: "PT2345", age: "55", previousProblems: "Arthritis", allergies: "None", medications: "Joint Fluid Analysis"),
        Patient(fullName: "Lisa White", generatedID: "PT6789", age: "40", previousProblems: "Migraine", allergies: "Ibuprofen", medications: "Blood Test")
    ]
    
    let categories = ["All", "Blood Count", "Lipid Panel", "Thyroid Function", "Glucose Test", "Cholesterol Test", "Allergy Test", "Joint Fluid Analysis", "Blood Test"]
    
    var filteredPatients: [Patient] {
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
                            Text(selectedCategory == "All" ? "All Patients" : selectedCategory)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.43, green: 0.34, blue: 0.99))
                            
                            Text("(\(filteredPatients.count))")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                        
                        // Patient Cards List
                        LazyVStack(spacing: 0) {
                            ForEach(filteredPatients, id: \.generatedID) { patient in
                                Button(action: {
                                    // Action for navigating to patient detail
                                    print("Selected patient: \(patient.fullName)")
                                }) {
                                    PatientCard(patient: patient)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Lab Technician")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HomeView_LT_Previews: PreviewProvider {
    static var previews: some View {
        HomeView_LT()
    }
}
