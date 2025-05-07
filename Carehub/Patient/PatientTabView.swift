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
            NavigationStack {
                HomeView_patient(patient: patient)
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            NavigationStack {
                DoctorView(patientId: patient.patientId)
            }
            .tabItem {
                Image(systemName: "stethoscope")
                Text("Doctor")
            }
            
            NavigationStack {
                ProfileView_patient(patient: patient)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .accentColor(Color(red: 0.43, green: 0.34, blue: 0.99))
    }
}
