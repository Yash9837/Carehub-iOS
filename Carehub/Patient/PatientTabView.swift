import SwiftUI

struct PatientTabView: View {
    let username: String
    let patient: Patient
    
    init(username: String, patient: Patient) {
        self.username = username
        self.patient = patient
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.selectionIndicatorTintColor = UIColor.green
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
            
            BookingView()
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
        .accentColor(.green)
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
