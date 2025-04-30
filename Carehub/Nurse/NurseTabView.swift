//
//  NurseTabView.swift
//  Carehub
//
//  Created by user@87 on 29/04/25.
//

import SwiftUI

struct NurseTabView: View {
    var nurseId: String
    var body: some View {
        TabView {
            NurseHomeView(nurseId: nurseId)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            NurseProfileView(nurseId: nurseId)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { // Added to set tab colors
            let tabBarAppearance = UITabBar.appearance()
            tabBarAppearance.tintColor = UIColor.purple // Selected tab color
            tabBarAppearance.unselectedItemTintColor = UIColor.gray // Unselected tab color
        }
    }
}
