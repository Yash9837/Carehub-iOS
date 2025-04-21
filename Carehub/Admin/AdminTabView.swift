//
//  AdminTabView.swift
//  Carehub
//
//  Created by Yash's Mackbook on 19/04/25.
//
import SwiftUI


// AdminTabView.swift
// AdminTabView.swift
struct AdminTabView: View {
    @State private var selectedTab = 0
    @StateObject private var staffManager = StaffManager()
    @StateObject private var authManager = AuthManager.shared
    
    var currentAdmin: Staff {
        authManager.currentStaffMember ?? Staff(
            fullName: "Admin",
            email: "admin@hospital.com",
            role: .admin,
            department: "Administration",
            phoneNumber: "555-0000"
        )
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AdminDashboardView(staffManager: staffManager, currentAdmin: currentAdmin)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            StaffListView(staffManager: staffManager)
                .tabItem {
                    Label("Staff", systemImage: "person.3.fill")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            AdminSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.43, green: 0.34, blue: 0.99))
        .navigationBarBackButtonHidden(true)
    }
}
// AdminDashboardView.swift
struct AdminDashboardView: View {
    @ObservedObject var staffManager: StaffManager
    let currentAdmin: Staff  // Add this
        
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsSection
                    quickActionsSection
                    recentActivitySection
                }
                .padding(.vertical)
            }
            .navigationTitle("Admin Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // In AdminTabView's toolbar:
                    NavigationLink(destination: AdminProfileView(admin: currentAdmin)) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                    }                }
            }
            
        }
    }
    
    // MARK: - Subviews
    
    private var statsSection: some View {
        Group {
            HStack(spacing: 15) {
                DashboardCard(
                    title: "Total Staff",
                    value: "\(staffManager.staffList.count)",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                DashboardCard(
                    title: "Doctors",
                    value: "\(staffManager.staffList.filter { $0.role == .doctor }.count)",
                    icon: "stethoscope",
                    color: .green
                )
            }
            
            HStack(spacing: 15) {
                DashboardCard(
                    title: "Nurses",
                    value: "\(staffManager.staffList.filter { $0.role == .nurse }.count)",
                    icon: "cross.case.fill",
                    color: .orange
                )
                
                DashboardCard(
                    title: "Lab Techs",
                    value: "\(staffManager.staffList.filter { $0.role == .labTechnician }.count)",
                    icon: "testtube.2",
                    color: .purple
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        Group {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                quickActionButton(
                    destination: AddStaffView(staffManager: staffManager),
                    title: "Add Staff",
                    icon: "person.badge.plus",
                    color: Color(red: 0.43, green: 0.34, blue: 0.99)
                )
                
                quickActionButton(
                    destination: StaffListView(staffManager: staffManager),
                    title: "Manage Staff",
                    icon: "person.3.sequence.fill",
                    color: .teal
                )
                
                quickActionButton(
                    destination: AnalyticsView(),
                    title: "View Reports",
                    icon: "chart.pie.fill",
                    color: .indigo
                )
                
                quickActionButton(
                    destination: AdminSettingsView(),
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var recentActivitySection: some View {
        RecentActivityView(staffManager: staffManager)
    }
    
    private func quickActionButton<Destination: View>(destination: Destination, title: String, icon: String, color: Color) -> some View {
        NavigationLink(destination: destination) {
            QuickActionButton1(
                title: title,
                icon: icon,
                color: color
            )
        }
    }
}

// DashboardCard.swift
struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// QuickActionButton.swift
struct  QuickActionButton1: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
