import SwiftUI

struct PatientTabView: View {
    let username: String
    let patient: PatientF
    
    init(username: String, patient: PatientF) {
        self.username = username
        self.patient = patient
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.selectionIndicatorTintColor = UIColor(red: 0.43, green: 0.34, blue: 0.99, alpha: 1.0)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView {
            HomeView_patient(patient: patient)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            DoctorView()
                .tabItem {
                    Image(systemName: "stethoscope")
                    Text("Doctor")
                }
            
            ProfileView_patient(patient: patient)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .navigationBarBackButtonHidden(true)
        .accentColor(Color(red: 0.43, green: 0.34, blue: 0.99))
    }
}
#Preview {
    let samplePatient = PatientF(
        emergencyContact: [EmergencyContact(Number: "1234567890", name: "Emergency Contact")],
        medicalRecords: [],
        testResults: [],
        userData: UserData(
            Address: "123 Main St, City",
            Dob: "01/01/1990",
            Email: "john@example.com",
            Name: "John Doe",
            Password: "hashedpassword",
            aadharNo: "123456789012",
            phoneNo: "9876543210"
        ),
        vitals: Vitals(
            allergies: ["Peanuts"],
            bp: [],
            heartRate: [],
            height: [],
            temperature: [],
            weight: []
        ),
        lastModified: Date(),
        patientId: "P123456"
    )
    return PatientTabView(username: "TestUser", patient: samplePatient)
}
