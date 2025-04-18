import SwiftUI

struct AdminTabView: View {
    var body: some View {
        TabView {
            HomeView_admin().tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            ManageView().tabItem {
                Image(systemName: "gear")
                Text("Manage")
            }
            
            ProfileView_admin().tabItem {
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
