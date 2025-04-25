import SwiftUI
import os.log

struct AdminTabView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var staffManager = StaffManager()
    @State private var selectedTab = 0
    @State private var showLogoutAlert = false
    private let logger = Logger(subsystem: "com.yourapp.Carehub", category: "AdminTab")
    
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
            AdminDashboardView(staffManager: staffManager)
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
            
            AdminProfileView(admin: admin)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .accentColor(.purple)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Logout") {
                    logger.debug("Logout button tapped")
                    showLogoutAlert = true
                }
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
