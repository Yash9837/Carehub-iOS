import SwiftUI

struct AdminTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            ManageView().tabItem {
                Image(systemName: "gear")
                Text("Manage")
            }
            
            ProfileView().tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
