//
//  LabTechTabView.swift
//  Carehub
//
//  Created by admin24 on 21/04/25.
//

import SwiftUI

struct LabTechTabView: View {
    var body: some View {
        TabView {
            HomeView_LT()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            Records_LT()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Records")
                }
            
            ProfileView_LT(labTechId: "WFQ7R40YZICIGLXRJDYOHDXDLKD3")                .tabItem {
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
