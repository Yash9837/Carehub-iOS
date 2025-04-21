import SwiftUI

struct ProfileView_patient: View {
    let patient: Patient
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header Section
                Section {
                    HStack {
                        // Circular avatar placeholder
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(.gray)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(patient.fullName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("ID: \(patient.generatedID)")
                                .font(.subheadline)
                                .foregroundStyle(Color(red: 0.43, green: 0.34, blue: 0.99)) // #6D57FC
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Personal Information").font(.headline)) {
                    ProfileRow(title: "Patient ID", value: patient.generatedID, icon: "number")
                    ProfileRow(title: "Full Name", value: patient.fullName, icon: "person.fill")
                    ProfileRow(title: "Age", value: patient.age, icon: "calendar")
                }
                
                // Medical Information Section
                Section(header: Text("Medical Information").font(.headline)) {
                    ProfileRow(title: "Previous Problems", value: patient.previousProblems.isEmpty ? "None" : patient.previousProblems, icon: "bandage")
                    ProfileRow(title: "Allergies", value: patient.allergies.isEmpty ? "None" : patient.allergies, icon: "allergens")
                    ProfileRow(title: "Current Medications", value: patient.medications.isEmpty ? "None" : patient.medications, icon: "pills")
                }
                
                // Actions Section
                Section {
                    NavigationLink(destination: EditProfileView(patient: patient)) {
                        Label("Edit Profile", systemImage: "pencil")
                            .foregroundStyle(.blue)
                    }
                    Button(action: {
                        // Handle sign-out logic
                    }) {
                        Label("Sign Out", systemImage: "arrow.right.circle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color(red: 0.43, green: 0.34, blue: 0.99)) // #6D57FC
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct EditProfileView: View {
    let patient: Patient
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Full Name", text: .constant(patient.fullName))
                TextField("Age", text: .constant(patient.age))
            }
            Section(header: Text("Medical Information")) {
                TextField("Previous Problems", text: .constant(patient.previousProblems))
                TextField("Allergies", text: .constant(patient.allergies))
                TextField("Current Medications", text: .constant(patient.medications))
            }
        }
        .navigationTitle("Edit Profile")
    }
}

#Preview {
    let samplePatient = Patient(
        fullName: "John Doe",
        generatedID: "P123456",
        age: "30",
        previousProblems: "Asthma",
        allergies: "Peanuts",
        medications: "Inhaler"
    )
    return ProfileView_patient(patient: samplePatient)
}
