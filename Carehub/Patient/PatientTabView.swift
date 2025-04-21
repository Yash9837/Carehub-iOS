import SwiftUI

struct PatientTabView: View {
    let username: String
    let patient: Patient
    
    init(username: String, patient: Patient) {
        self.username = username
        self.patient = patient
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.selectionIndicatorTintColor = UIColor(red: 0.43, green: 0.34, blue: 0.99, alpha: 1.0) // #6D57FC
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView {
            HomeView_patient(username: username)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            ScheduleAppointmentView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Booking")
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
        .accentColor(Color(red: 0.43, green: 0.34, blue: 0.99)) // #6D57FC
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
    return PatientTabView(username: "TestUser", patient: samplePatient)
}
