import SwiftUI

struct DoctorTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            PatientView().tabItem {
                Image(systemName: "cross.case")
                Text("Patient")
            }
            
            ProfileView().tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
