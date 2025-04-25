<<<<<<< Updated upstream
<<<<<<< Updated upstream
//
//  AdminTabView.swift
//  Carehub
//
//  Created by Yash's Mackbook on 19/04/25.
//
import SwiftUI


// AdminTabView.swift
// AdminTabView.swift
=======
import SwiftUI
import os.log

>>>>>>> Stashed changes
struct AdminTabView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var staffManager = StaffManager()
<<<<<<< Updated upstream
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
=======
    @State private var selectedTab = 0
    @State private var showLogoutAlert = false
    private let logger = Logger(subsystem: "com.yourapp.Carehub", category: "AdminTab")
>>>>>>> Stashed changes
=======
import SwiftUI
import os.log

struct AdminTabView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var staffManager = StaffManager()
    @State private var selectedTab = 0
    @State private var showLogoutAlert = false
    private let logger = Logger(subsystem: "com.yourapp.Carehub", category: "AdminTab")
>>>>>>> Stashed changes
    
    var body: some View {
        ZStack {
            if authManager.isLoading {
                ProgressView("Loading admin data...")
                    .onAppear {
                        logger.debug("Loading admin data...")
                    }
            } else if let admin = authManager.currentStaffMember, admin.role == .admin {
                mainTabView(admin: admin)
            } else {
                accessDeniedView
            }
        }
    }
    
    @ViewBuilder
    private func mainTabView(admin: Staff) -> some View {
        TabView(selection: $selectedTab) {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            AdminDashboardView(staffManager: staffManager, currentAdmin: currentAdmin)
=======
=======
>>>>>>> Stashed changes
            AdminDashboardView(staffManager: staffManager)
>>>>>>> Stashed changes
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
            
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            AdminSettingsView()
=======
            AdminProfileView(admin: admin)
>>>>>>> Stashed changes
=======
            AdminProfileView(admin: admin)
>>>>>>> Stashed changes
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .accentColor(.purple)
        .navigationBarBackButtonHidden(true)
<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
=======
=======
>>>>>>> Stashed changes
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Logout") {
                    logger.debug("Logout button tapped")
                    showLogoutAlert = true
                }
<<<<<<< Updated upstream
>>>>>>> Stashed changes
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
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                logger.debug("User confirmed logout")
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            logger.debug("AdminTabView appeared for user")
        }
    }
    
    private var accessDeniedView: some View {
        VStack(spacing: 20) {
            Text("Access Denied")
                .font(.title)
            Text(authManager.errorMessage ?? "You don't have admin privileges")
            
            Button("Logout") {
                logger.debug("Logging out unauthorized user")
                authManager.logout()
            }
            .padding()
        }
        .onAppear {
            if authManager.currentStaffMember?.role != .admin {
                logger.error("Unauthorized access attempt by user: \(authManager.currentStaffMember?.id ?? "unknown")")
            }
        }
    }
}
<<<<<<< Updated upstream

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
=======
>>>>>>> Stashed changes
=======
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                logger.debug("User confirmed logout")
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            logger.debug("AdminTabView appeared for user")
        }
    }
    
    private var accessDeniedView: some View {
        VStack(spacing: 20) {
            Text("Access Denied")
                .font(.title)
            Text(authManager.errorMessage ?? "You don't have admin privileges")
            
            Button("Logout") {
                logger.debug("Logging out unauthorized user")
                authManager.logout()
            }
            .padding()
        }
        .onAppear {
            if authManager.currentStaffMember?.role != .admin {
                logger.error("Unauthorized access attempt by user: \(authManager.currentStaffMember?.id ?? "unknown")")
            }
        }
    }
}
>>>>>>> Stashed changes
