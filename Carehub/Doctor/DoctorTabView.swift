import SwiftUI

struct DoctorTabView: View {
    var body: some View {
        TabView {
            HomeView_doc()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            PatientView()
                .tabItem {
                    Image(systemName: "cross.case")
                    Text("Patient")
                }
            
            ProfileView_doc()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { // Added to set tab colors
            let tabBarAppearance = UITabBar.appearance()
            tabBarAppearance.tintColor = UIColor.green // Selected tab color
            tabBarAppearance.unselectedItemTintColor = UIColor.gray // Unselected tab color
        }
    }
}
