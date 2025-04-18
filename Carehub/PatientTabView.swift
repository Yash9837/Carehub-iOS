import SwiftUI

struct PatientTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            BookingView().tabItem {
                Image(systemName: "calendar")
                Text("Booking")
            }
            
            DoctorView().tabItem {
                Image(systemName: "stethoscope")
                Text("Doctor")
            }
            
            ProfileView().tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
