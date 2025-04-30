import SwiftUI

struct Patient: Identifiable {
    let id = UUID()
    let name: String
    let gender: String
    let visitDate: String
    let patientId: String
}

struct MyPatientsView: View {
    @State private var searchText = ""
    
    let patients = [
        Patient(name: "John Doe", gender: "Male", visitDate: "Visited: 23 Apr 2025 at 3:48 PM", patientId: "PT001"),
        Patient(name: "Emily Johnson", gender: "Female", visitDate: "Visited: 22 Apr 2025 at 3:48 PM", patientId: "PT002"),
        Patient(name: "Michael Brown", gender: "Male", visitDate: "Visited: 20 Apr 2025 at 3:48 PM", patientId: "PT003")
    ]
    
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
                Text(patient.gender)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
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

// Main TabView to wrap the app
struct ContentView: View {
    var body: some View {
        TabView {
            MyPatientsView()
                .tabItem {
                    Label("Patients", systemImage: "person.3")
                }
            
            // Add other tabs as needed
            Text("Appointments")
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

struct MyPatientsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
